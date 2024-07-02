import { Command, Option } from "commander";
import { createReadStream, readFileSync } from "fs";
import { createInterface } from "node:readline";
import { Interface } from "readline";

export abstract class UnipeptSubcommand {
  public command: Command;
  static readonly VALID_FORMATS = ["blast", "csv", "json", "xml"];
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  options: any = {};
  name: string;
  user_agent: string;
  host = "https://api.unipept.ugent.be";
  url?: string;

  constructor(name: string) {
    this.name = name;
    const version = JSON.parse(readFileSync(new URL("../../../package.json", import.meta.url), "utf8")).version;
    this.user_agent = `unipept-cli/${version}`;
    this.command = this.create(name);
  }

  create(name: string): Command {
    const command = new Command(name);

    command.option("-q, --quiet", "disable service messages");
    command.option("-i, -input <file>", "read input from file");
    command.option("-o, --output <file>", "write output to file");
    command.addOption(new Option("-f, --format <format>", "define the output format").choices(UnipeptSubcommand.VALID_FORMATS).default("json"));
    command.option("--host <host>", "specify the server running the Unipept web service");

    // internal options
    command.addOption(new Option("--no-header", "disable the header in csv output").hideHelp());
    command.addOption(new Option("--batch <size>", "specify the batch size").hideHelp());

    return command;
  }

  async run(args: string[], options: object): Promise<void> {
    this.options = options;
    this.host = this.getHost();
    this.url = `${this.host}/api/v2/${this.name}.json`;

    let slice = [];

    for await (const input of this.getInputIterator(args, options)) {
      slice.push(input);
      if (slice.length >= this.defaultBatchSize()) {
        await this.processBatch(slice);
        slice = [];
      }
    }
    await this.processBatch(slice);
  }

  async processBatch(slice: string[]): Promise<void> {
    const r = await fetch(this.url as string, {
      method: "POST",
      body: new URLSearchParams({ "input": JSON.stringify(slice) }),
      headers: {
        "Accept-Encoding": "gzip",
        "User-Agent": this.user_agent,
      }
    });
    console.log(await r.json());
  }

  /**
   * Returns an input iterator to use for the request.
   * - if arguments are given, use arguments
   * - if an input file is given, use the file
   * - otherwise, use standard input
   */
  getInputIterator(args: string[], options: { input?: string }): string[] | Interface {
    if (args.length > 0) {
      return args;
    } else if (options.input) {
      return createInterface({ input: createReadStream(options.input) });
    } else {
      return createInterface({ input: process.stdin })
    }
  }


  abstract defaultBatchSize(): number;

  private getHost(): string {
    const host = this.options.host || this.host;

    // add http:// if needed
    if (host.startsWith("http://") || host.startsWith("https://")) {
      return host;
    } else {
      return `http://${host}`;
    }
  }
}
