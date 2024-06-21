import { createInterface } from 'node:readline';
import { BaseCommand } from './base_command.js';

export class Prot2pept extends BaseCommand {

  readonly description = `The prot2pept command splits each protein sequence into a list of peptides according to a given cleavage-pattern. The command expects a list of protein sequences that are passed to standard input.

The input should have either one protein sequence per line or contain a FASTA formatted list of protein sequences. FASTA headers are preserved in the output, so that peptides can be bundled per protein sequence.
`;

  constructor(options?: { exitOverride?: boolean, suppressOutput?: boolean, args?: string[] }) {
    super(options);

    this.program
      .summary("Splits each protein sequence into a list of peptides.")
      .description(this.description)
      .option("-p, --pattern <regex>", "specify cleavage-pattern (regex) as the pattern after which the next peptide will be cleaved. By default, it will create tryptic peptides.", "([KR])([^P])")
  }

  /**
   * Performance note: Just as with peptfilter, this implementation can be made faster by using line events instead of
   * async iterators.
   */
  async run() {
    this.parseArguments();
    const pattern = new RegExp(this.program.opts().pattern, "g");

    let fasta = false;
    let protein = [];

    // buffering output makes a big difference in performance
    let output = [];
    let i = 0;

    for await (const line of createInterface({ input: process.stdin })) {
      if (i === 0 && line.startsWith(">")) {
        fasta = true;
      }

      i++;

      if (fasta) { // if we're in fasta mode, a protein could be split over multiple lines
        if (line.startsWith(">")) { // if we encounter a new header, process the previous protein and output the current header
          if (protein.length > 0) {
            output.push(Prot2pept.splitProtein(protein.join(""), pattern));
          }
          output.push(line.trimEnd());
          protein = [];
        } else {
          protein.push(line.trimEnd());
        }
      } else { // if we're not in fasta mode, each line is a protein sequence
        output.push(Prot2pept.splitProtein(line.trimEnd(), pattern));
      }

      if (i % 1000 === 0) {
        output.push(""); //add a newline at the end of the buffer without additional string copy
        process.stdout.write(output.join("\n"));
        output = [];
      }
    }

    if (fasta) { // if in fasta mode, process the last protein
      output.push(Prot2pept.splitProtein(protein.join(""), pattern));
    }
    output.push("");
    process.stdout.write(output.join("\n"));
  }

  static splitProtein(line: string, pattern: RegExp): string {
    return line.replaceAll(pattern, "$1\n$2").replaceAll(pattern, "$1\n$2").replaceAll("\n\n", "\n");
  }
}
