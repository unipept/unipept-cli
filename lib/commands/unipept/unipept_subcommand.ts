import { Command, Option } from "commander";
import { createReadStream, createWriteStream, readFileSync } from "fs";
import { createInterface } from "node:readline";
import { Interface } from "readline";
import { Formatter } from "../../formatters/formatter.js";
import { FormatterFactory } from "../../formatters/formatter_factory.js";

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

  // we must save this to be able to close it properly in tests
  private streamInterface?: Interface;

  constructor(name: string) {
    this.name = name;
    const version = JSON.parse(readFileSync(new URL("../../../package.json", import.meta.url), "utf8")).version;
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
      process.stdout.on("error", (err) => {
        if (err.code === "EPIPE") {
          process.exit(0);
        }
      })
    }

    const iterator = this.getInputIterator(args, options.input as string);
    const firstLine = (await iterator.next()).value;
    if (firstLine.startsWith(">")) {
      this.fasta = true;
      await this.fastaInputProcessor(firstLine, iterator);
    } else {
      await this.normalInputProcessor(firstLine, iterator);
    }
  }

  async processBatch(slice: string[], fastaMapper?: { [key: string]: string }): Promise<void> {
    if (!this.formatter) throw new Error("Formatter not set");

    const r = await fetch(this.url as string, {
      method: "POST",
      body: this.constructRequestBody(slice),
      headers: {
        "Accept-Encoding": "gzip",
        "User-Agent": this.user_agent,
      }
    });
    const result = await r.json();

    if (this.firstBatch && this.options.header) {
      this.outputStream.write(this.formatter.header(result, this.fasta));
    }

    this.outputStream.write(this.formatter.format(result, fastaMapper, this.firstBatch));

    if (this.firstBatch) this.firstBatch = false;
  }

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

  private constructRequestBody(slice: string[]): URLSearchParams {
    const names = this.getSelectedFields().length === 0 || this.getSelectedFields().some(regex => regex.toString().includes("name") || regex.toString().includes(".*$"));
    return new URLSearchParams({
      input: JSON.stringify(slice),
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
