import { Option } from "commander";
import { UnipeptSubcommand } from "./unipept_subcommand.js";

export class Protinfo extends UnipeptSubcommand {

  readonly description = `For each UniProt id the unipept protinfo command retrieves from Unipept the functional information and the NCBI id. The command expects a list of UniProt ids that are passed

- as separate command line arguments
- in a text file that is passed as an argument to the -i option
- to standard input

The command will give priority to the first way protein id's are passed, in the order as listed above. Text files and standard input should have one protein id per line.`;

  constructor() {
    super("protinfo");

    this.command
      .summary("Fetch functional and taxonomic information of UniProt ids")
      .description(this.description)
      .addOption(new Option("-s --select <fields...>", "select the information fields to return. Selected fields are passed as a comma separated list of field names. Multiple -s (or --select) options may be used."))
      .argument("[proteins...]", "optionally, 1 or more UniProt ids")
      .action((args, options) => this.run(args, options));
  }

  requiredFields(): string[] {
    return ["protein"];
  }

  defaultBatchSize(): number {
    return 1000;
  }
}
