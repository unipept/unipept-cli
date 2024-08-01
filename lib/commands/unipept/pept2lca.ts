import { Option } from "commander";
import { UnipeptSubcommand } from "./unipept_subcommand.js";

export class Pept2lca extends UnipeptSubcommand {

  readonly description = `For each tryptic peptide the unipept pept2lca command retrieves from Unipept the lowest common ancestor of the set of taxa from all UniProt entries whose protein sequence contains an exact matches to the tryptic peptide. The lowest common ancestor is based on the topology of the Unipept Taxonomy -- a cleaned up version of the NCBI Taxonomy -- and is itself a record from the NCBI Taxonomy. The command expects a list of tryptic peptides that are passed

- as separate command line arguments
- in a text file that is passed as an argument to the -i option
- to standard input

The command will give priority to the first way tryptic peptides are passed, in the order as listed above. Text files and standard input should have one tryptic peptide per line.`;

  constructor() {
    super("pept2lca");

    this.command
      .summary("Fetch taxonomic lowest common ancestor of UniProt entries that match tryptic peptides.")
      .description(this.description)
      .option("-e, --equate", "equate isoleucine (I) and leucine (L) when matching peptides")
      .option("-a, --all", "report all information fields of NCBI Taxonomy records available in Unipept. Note that this may have a performance penalty.")
      .addOption(new Option("-s --select <fields...>", "select the information fields to return. Selected fields are passed as a comma separated list of field names. Multiple -s (or --select) options may be used."))
      .argument("[peptides...]", "optionally, 1 or more peptides")
      .action((args, options) => this.run(args, options));
  }

  requiredFields(): string[] {
    return ["peptide"];
  }

  defaultBatchSize(): number {
    return 100;
  }
}
