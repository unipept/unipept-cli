import { Option } from "commander";
import { UnipeptSubcommand } from "./unipept_subcommand.js";

export class Taxa2lca extends UnipeptSubcommand {

  readonly description = `The unipept taxa2lca command computes the lowest common ancestor of a given list of NCBI Taxonomy Identifiers. The lowest common ancestor is based on the topology of the Unipept Taxonomy -- a cleaned up version of the NCBI Taxonomy -- and is itself a record from the NCBI Taxonomy. The command expects a list of NCBI Taxonomy Identifiers that are passed

- as separate command line arguments
- in a text file that is passed as an argument to the -i option
- to standard input

The command will give priority to the first way NCBI Taxonomy Identifiers are passed, in the order as listed above. Text files and standard input should have one tryptic peptide per line.`;

  constructor() {
    super("taxa2lca");

    this.command
      .summary("Compute taxonomic lowest common ancestor for given list of taxa.")
      .description(this.description)
      .option("-a, --all", "report all information fields of NCBI Taxonomy records available in Unipept. Note that this may have a performance penalty.")
      .addOption(new Option("-s --select <fields...>", "select the information fields to return. Selected fields are passed as a comma separated list of field names. Multiple -s (or --select) options may be used."))
      .argument("[taxonids...]", "optionally, 1 or more taxon ids")
      .action((args, options) => this.run(args, options));
  }

  defaultBatchSize(): number {
    throw new Error("Batch size not needed for this command.");
  }
}
