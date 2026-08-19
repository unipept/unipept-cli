import { BaseCommand } from './base_command.js';
import { InputSource } from '../io/input.js';
import { OutputWriter } from '../io/output.js';

export class Prot2pept extends BaseCommand {

  readonly description = `The prot2pept command splits each protein sequence into a list of peptides according to a given cleavage-pattern. The command expects a list of protein sequences that are passed to standard input.

The input should have either one protein sequence per line or contain a FASTA formatted list of protein sequences. FASTA headers are preserved in the output, so that peptides can be bundled per protein sequence.
`;

  constructor(options?: { exitOverride?: boolean, suppressOutput?: boolean }) {
    super(options);

    this.program
      .summary("Splits each protein sequence into a list of peptides.")
      .description(this.description)
      .option("-p, --pattern <regex>", "specify cleavage-pattern (regex) as the pattern after which the next peptide will be cleaved. By default, it will create tryptic peptides.", "([KR])([^P])");

    this.addIoOptions();
  }

  /**
   * Performance note: Just as with peptfilter, this implementation can be made faster by using line events instead of
   * async iterators.
   */
  async run(args?: string[]) {
    this.parseArguments(args);

    let pattern;
    try {
      pattern = new RegExp(this.program.opts().pattern, "g");
    } catch (e) {
      this.program.error(`Your pattern was invalid: ${(e as Error).message}`);
    }

    let fasta = false;
    let protein = [];
    let first = true;

    const input = new InputSource();
    const output = new OutputWriter(this.program.opts().output);

    try {
      for await (const line of input.lines([], this.program.opts().input)) {
        if (first && line.startsWith(">")) {
          fasta = true;
        }
        first = false;

        if (fasta) { // if we're in fasta mode, a protein could be split over multiple lines
          if (line.startsWith(">")) { // if we encounter a new header, process the previous protein and output the current header
            if (protein.length > 0) {
              output.line(Prot2pept.splitProtein(protein.join(""), pattern));
            }
            output.line(line.trimEnd());
            protein = [];
          } else {
            protein.push(line.trimEnd());
          }
        } else { // if we're not in fasta mode, each line is a protein sequence
          output.line(Prot2pept.splitProtein(line.trimEnd(), pattern));
        }
      }
    } catch (e) {
      this.program.error((e as Error).message);
    }

    if (fasta && protein.length > 0) { // if in fasta mode, process the last protein
      output.line(Prot2pept.splitProtein(protein.join(""), pattern));
    }

    await output.close();
  }

  static splitProtein(line: string, pattern: RegExp): string {
    return line.replaceAll(pattern, "$1\n$2").replaceAll(pattern, "$1\n$2").replaceAll("\n\n", "\n");
  }
}
