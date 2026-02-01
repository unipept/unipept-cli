import { Command, Option } from "commander";
import { createReadStream, createWriteStream, readFileSync } from "fs";
import { createInterface } from "node:readline";
import { Interface } from "readline";
import { Formatter } from "../../formatters/formatter.js";
import { FormatterFactory } from "../../formatters/formatter_factory.js";
import { CSVFormatter } from "../../formatters/csv_formatter.js";
import path from "path";
import os from "os";
import { appendFile, mkdir } from "fs/promises";

export abstract class UnipeptSubcommand {
  public command: Command;
  static readonly VALID_FORMATS = ["blast", "csv", "json", "xml"];
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  options: any = {};
  name: string;
  user_agent: string;
  host = "https://api.unipept.ugent.be";
  url?: string;
  formatter?: Formatter;
  outputStream: NodeJS.WritableStream = process.stdout;
  firstBatch = true;
  selectedFields?: RegExp[];
  fasta: boolean;
  castInput = false;

  // we must save this to be able to close it properly in tests
  private streamInterface?: Interface;

  constructor(name: string) {
    this.name = name;
    let p = "";
    if (import.meta.url.includes("/dist/")) {
      p = "../";
    }
    const version = JSON.parse(readFileSync(new URL(p + "../../../package.json", import.meta.url), "utf8")).version;
    this.user_agent = `unipept-cli/${version}`;
    this.command = this.create(name);
    this.fasta = false;
  }

  abstract defaultBatchSize(): number;

  requiredFields(): string[] {
    return [];
  }

  create(name: string): Command {
    const command = new Command(name);

    command.option("-q, --quiet", "disable service messages");
    command.option("-i, --input <file>", "read input from file");
    command.option("-o, --output <file>", "write output to file");
    command.addOption(new Option("-f, --format <format>", "define the output format").choices(UnipeptSubcommand.VALID_FORMATS).default("csv"));
    command.option("--host <host>", "specify the server running the Unipept web service");

    // internal options
    command.addOption(new Option("--no-header", "disable the header in csv output").hideHelp());
    command.addOption(new Option("--batch <size>", "specify the batch size").hideHelp());

    return command;
  }

  async run(args: string[], options: { [key: string]: unknown }): Promise<void> {
    this.options = options;
    this.host = this.getHost();
    this.url = `${this.host}/api/v2/${this.name}.json`;
    this.formatter = FormatterFactory.getFormatter(this.options.format);

    if (this.options.output) {
      this.outputStream = createWriteStream(this.options.output);
    } else {
      // if we write to stdout, we need to handle the EPIPE error
      // this happens when the output is piped to another command that stops reading
      process.stdout.on("error", (err) => {
        if (err.code === "EPIPE") {
          process.exit(0);
        }
      })
    }

    const iterator = this.getInputIterator(args, options.input as string);
    const firstLine = (await iterator.next()).value;
    if (this.command.name() === "taxa2lca") {
      // this subcommand is an exception where the entire input is read before processing
      await this.simpleInputProcessor(firstLine, iterator);
    } else if (firstLine.startsWith(">")) {
      this.fasta = true;
      await this.fastaInputProcessor(firstLine, iterator);
    } else {
      await this.normalInputProcessor(firstLine, iterator);
    }
  }

  async processBatch(slice: string[], fastaMapper?: { [key: string]: string }): Promise<void> {
    if (!this.formatter) throw new Error("Formatter not set");

    let r;
    try {
      r = await this.fetchWithRetry(this.url as string, {
        method: "POST",
        body: this.constructRequestBody(slice),
        headers: {
          "Content-Type": "application/json",
          "Accept-Encoding": "gzip",
          "User-Agent": this.user_agent,
        }
      });
    } catch (e) {
      await this.saveError(e as string);
      return;
    }

    let result;
    try {
      result = await r.json();
    } catch (e) {
      result = [];
    }
    if (Array.isArray(result) && result.length === 0) return;
    result = this.filterResult(result);

    if (this.firstBatch && this.options.header) {
      this.outputStream.write(this.formatter.header(result, this.fasta));
    }

    this.outputStream.write(this.formatter.format(result, fastaMapper, this.firstBatch));

    if (this.firstBatch) this.firstBatch = false;
  }

  /**
   * Filter the result based on the selected fields
   */
  filterResult(result: unknown): object[] {
    if (!Array.isArray(result)) {
      result = [result];
    }
    if (this.formatter && this.formatter instanceof CSVFormatter) {
      result = this.formatter.flatten(result as { [key: string]: unknown }[]);
    }
    if (this.getSelectedFields().length > 0) {
      (result as { [key: string]: string }[]).forEach(entry => {
        for (const key of Object.keys(entry)) {
          if (!this.getSelectedFields().some(regex => regex.test(key))) {
            delete entry[key];
          }
        }
      });
    }
    return result as object[];
  }

  /**
   * Reads batchSize lines from the input and processes them
   */
  async normalInputProcessor(firstLine: string, iterator: IterableIterator<string> | AsyncIterableIterator<string>) {
    let slice = [firstLine];

    for await (const line of iterator) {
      slice.push(line);
      if (slice.length >= this.batchSize) {
        await this.processBatch(slice);
        slice = [];
      }
    }
    await this.processBatch(slice);
  }

  /**
   * Reads batchSize lines from the input and processes them,
   * but takes into account the fasta headers.
   */
  async fastaInputProcessor(firstLine: string, iterator: IterableIterator<string> | AsyncIterableIterator<string>) {
    let currentFastaHeader = firstLine;
    let slice = [];
    let fastaMapper: { [key: string]: string } = {};
    for await (const line of iterator) {
      if (line.startsWith(">")) {
        currentFastaHeader = line;
      } else {
        fastaMapper[line] = currentFastaHeader;
        slice.push(line);
        if (slice.length >= this.batchSize) {
          await this.processBatch(slice, fastaMapper);
          slice = [];
          fastaMapper = {};
        }
      }
    }
    await this.processBatch(slice, fastaMapper);
  }

  /**
   * Reads the entire input and processes it in one go
   */
  async simpleInputProcessor(firstLine: string, iterator: IterableIterator<string> | AsyncIterableIterator<string>) {
    const slice = [firstLine];
    for await (const line of iterator) {
      slice.push(line);
    }
    await this.processBatch(slice);
  }

  /**
   * Appends the error message to the log file of today and prints it to the console
   */
  async saveError(message: string) {
    const errorPath = this.errorFilePath();
    await mkdir(path.dirname(errorPath), { recursive: true });
    await appendFile(errorPath, `${message}\n`);
    console.error(`API request failed: ${message}`);
    console.error(`Log can be found in ${errorPath}`);
  }

  /**
   * Uses fetch to get data from the Unipept API.
   * Has a retry mechanism that retries the request up to 5 times with a delay of 0-5 seconds.
   * In addition, handles failed requests by returning a rejected promise.
   */
  fetchWithRetry(url: string, options: RequestInit, retries = 5): Promise<Response> {
    return fetch(url, options)
      .then(response => {
        if (response.ok) {
          return response;
        } else {
          return Promise.reject(`${response.status} ${response.statusText}`);
        }
      })
      .catch(async error => {
        let shouldRetry = retries > 0;

        // check if we should stop retrying based on error message (from the reject above)
        if (typeof error === 'string') {
          const status = parseInt(error.split(' ')[0]);
          if (status >= 400 && status < 500 && status !== 429) {
            shouldRetry = false;
          }
        }

        if (shouldRetry) {
          // retry with delay
          const delay = Math.ceil(5000 * Math.random());
          process.stderr.write(`> Request failed: ${error}. Retrying in ${(delay / 1000).toFixed(1)}s...\n`);
          await new Promise(resolve => setTimeout(resolve, delay));
          return this.fetchWithRetry(url, options, retries - 1);
        } else {
          return Promise.reject(`Failed to fetch data from the Unipept API: ${error}`);
        }
      });
  }

  private constructRequestBody(slice: string[]): string {
    const names = this.getSelectedFields().length === 0 || this.getSelectedFields().some(regex => regex.toString().includes("name") || regex.toString().includes(".*$"));
    let input: string[] | number[] = slice;
    if (this.castInput) {
      input = slice.map(s => parseInt(s, 10));
    }
    return JSON.stringify({
      input: input,
      equate_il: this.options.equate,
      extra: this.options.all,
      names: this.options.all && names
    });
  }

  private getSelectedFields(): RegExp[] {
    if (this.selectedFields) return this.selectedFields;

    const fields = (this.options.select as string[])?.flatMap(f => f.split(",")) ?? [];
    if (this.fasta && fields.length > 0) {
      fields.push(...this.requiredFields());
    }
    this.selectedFields = fields.map(f => this.globToRegex(f));

    return this.selectedFields;
  }

  private get batchSize(): number {
    if (this.options.batch) {
      return +this.options.batch;
    } else {
      return this.defaultBatchSize();
    }
  }

  private errorFilePath(): string {
    const timestamp = new Date().toISOString().split('T')[0];
    return path.join(os.homedir(), '.unipept', `unipept-${timestamp}.log`);
  }

  /**
   * Returns an input iterator to use for the request.
   * - if arguments are given, use arguments
   * - if an input file is given, use the file
   * - otherwise, use standard input
   */
  private getInputIterator(args: string[], input?: string): IterableIterator<string> | AsyncIterableIterator<string> {
    if (args.length > 0) {
      return args.values();
    } else if (input) {
      this.streamInterface = createInterface({ input: createReadStream(input) });
      return this.streamInterface[Symbol.asyncIterator]();
    } else {
      if (process.stdin.isTTY) {
        const eofKey = process.platform === "win32" ? "Ctrl+Z, Enter" : "Ctrl+D";
        process.stderr.write(`Reading from standard input... (Press ${eofKey} to finish)\n`);
      }
      this.streamInterface = createInterface({ input: process.stdin });
      return this.streamInterface[Symbol.asyncIterator]();
    }
  }

  private getHost(): string {
    const host = this.options.host || this.host;

    // add http:// if needed
    if (host.startsWith("http://") || host.startsWith("https://")) {
      return host;
    } else {
      return `http://${host}`;
    }
  }

  private globToRegex(glob: string): RegExp {
    return new RegExp(`^${glob.replace(/\*/g, ".*")}$`);
  }
}
