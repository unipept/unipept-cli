import { Option } from "commander";
import { UnipeptSubcommand } from "./unipept_subcommand.js";

export class Taxonomy extends UnipeptSubcommand {

  readonly description = `The unipept taxonomy command yields information from the Unipept Taxonomy records for a given list of NCBI Taxonomy Identifiers. The Unipept Taxonomy is a cleaned up version of the NCBI Taxonomy, and its records are also records of the NCBI Taxonomy. The command expects a list of NCBI Taxonomy Identifiers that are passed

- as separate command line arguments
- in a text file that is passed as an argument to the -i option
- to standard input

The command will give priority to the first way taxon id's are passed, in the order as listed above. Text files and standard input should have one taxon id per line.`;

  constructor() {
    super("taxonomy");

    this.command
      .summary("Fetch taxonomic information from Unipept Taxonomy.")
      .description(this.description)
      .option("-a, --all", "report all information fields of NCBI Taxonomy records available in Unipept. Note that this may have a performance penalty.")
      .addOption(new Option("-s --select <fields...>", "select the information fields to return. Selected fields are passed as a comma separated list of field names. Multiple -s (or --select) options may be used."))
      .argument("[peptides...]", "optionally, 1 or more peptides")
      .action((args, options) => this.run(args, options));
  }

  requiredFields(): string[] {
    return ["taxon_id"];
  }

  defaultBatchSize(): number {
    return 100;
  }
}
