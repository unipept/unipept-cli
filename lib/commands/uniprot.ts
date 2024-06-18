import { Option } from 'commander';
import { createInterface } from 'node:readline';
import { BaseCommand } from './base_command.js';

export class Uniprot extends BaseCommand {
  readonly VALID_FORMATS = ["fasta", "gff", "json", "rdf", "sequence", "xml"];

  readonly description = `Command line interface to UniProt web services.

The uniprot command fetches UniProt entries from the UniProt web services. The command expects a list of UniProt Accession Numbers that are passed

- as separate command line arguments
- to standard input

The command will give priority to the first way UniProt Accession Numbers are passed, in the order as listed above. The standard input should have one UniProt Accession Number per line.

The uniprot command yields just the protein sequences as a default, but can return several formats.`;
  format = "sequence";

  constructor() {
    super();

    this.program
      .summary("Command line interface to UniProt web services.")
      .description(this.description)
      .argument("[accessions...]", "UniProt Accession Numbers")
      .addOption(new Option("-f, --format <format>", `output format`).choices(this.VALID_FORMATS).default("sequence"));
  }

  async run() {
    this.program.parse(process.argv);
    this.format = this.program.opts().format;
    const accessions = this.program.args;

    if (accessions.length !== 0) { // input from command line arguments
      accessions.forEach(this.processUniprotEntry);
    } else { // input from standard input
      for await (const line of createInterface({ input: process.stdin })) {
        this.processUniprotEntry(line.trim());
      };
    }
  }

  /**
   * Fetches a UniProt entry and writes it to standard output.
   *
   * @param accession UniProt Accession Number
   */
  async processUniprotEntry(accession: string) {
    process.stdout.write(await Uniprot.getUniprotEntry(accession, this.format) + "\n");
  }

  /**
   * Fetches a UniProt entry in the requested format.
   *
   * @param accession UniProt Accession Number
   * @param format output format
   * @returns UniProt entry in the requested format
   */
  static async getUniprotEntry(accession: string, format: string): Promise<string> {
    // The UniProt REST API does not support the "sequence" format, so fetch fasta and remove the header
    if (format === "sequence") {
      return (await Uniprot.getUniprotEntry(accession, "fasta"))
        .split("\n")
        .slice(1)
        .join("");
    } else {
      const r = await fetch(`https://rest.uniprot.org/uniprotkb/${accession}.${format}`);
      if (r.ok) {
        return r.text();
      } else {
        process.stderr.write(`Error fetching ${accession}: ${r.status} ${r.statusText}\n`);
        return "";
      }
    }
  }
}
