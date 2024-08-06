import { Option } from "commander";
import { UnipeptSubcommand } from "./unipept_subcommand.js";

export class Pept2prot extends UnipeptSubcommand {

  readonly description = `For each tryptic peptide the unipept pept2prot command retrieves from Unipept all UniProt entries whose protein sequence contains an exact matches to the tryptic peptide. The command expects a list of tryptic peptides that are passed

- as separate command line arguments
- in a text file that is passed as an argument to the -i option
- to standard input

The command will give priority to the first way tryptic peptides are passed, in the order as listed above. Text files and standard input should have one tryptic peptide per line.`;

  constructor() {
    super("pept2prot");

    this.command
      .summary("Fetch UniProt entries that match tryptic peptides.")
      .description(this.description)
      .option("-e, --equate", "equate isoleucine (I) and leucine (L) when matching peptides")
      .option("-a, --all", "Also return the names of the EC numbers. Note that this may have a performance penalty.")
      .addOption(new Option("-s --select <fields...>", "select the information fields to return. Selected fields are passed as a comma separated list of field names. Multiple -s (or --select) options may be used."))
      .argument("[peptides...]", "optionally, 1 or more peptides")
      .action((args, options) => this.run(args, options));
  }

  requiredFields(): string[] {
    return ["peptide"];
  }

  defaultBatchSize(): number {
    if (this.options.all) {
      return 5;
    } else {
      return 10;
    }
  }
}
