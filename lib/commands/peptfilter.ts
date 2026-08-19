import { BaseCommand } from './base_command.js';
import { InputSource } from '../io/input.js';
import { OutputWriter } from '../io/output.js';

export class Peptfilter extends BaseCommand {

  readonly description = `The peptfilter command filters a list of peptides according to specific criteria. The command expects a list of peptides that are passed to standard input.

The input should have one peptide per line. FASTA headers are preserved in the output, so that peptides remain bundled.`;

  constructor(options?: { exitOverride?: boolean, suppressOutput?: boolean }) {
    super(options);

    this.program
      .summary("Filter peptides based on specific criteria.")
      .description(this.description)
      .option("--minlen <length>", "only retain peptides having at least this many amino acids", (d) => parseInt(d, 10), 5)
      .option("--maxlen <length>", "only retain peptides having at most this many amino acids", (d) => parseInt(d, 10), 50)
      .option("-l, --lacks <amino acids>", "only retain peptides that lack all of the specified amino acids", (d) => d.split(""))
      .option("-c, --contains <amino acids>", "only retain peptides that contain all of the specified amino acids", (d) => d.split(""))
      .option("-u, --unique", "only retain the first occurrence of each peptide");

    this.addIoOptions();
  }

  /**
   * Performance note: this implementation takes 4 seconds to run on swissprot. It can be made faster by using line events instead of
   * async iterators. This alternative implementation runs in 2.5 seconds. However, I decided that the async iterator implementation is
   * both more readable and more in line with the implementation of the other commands.
   */
  async run(args?: string[]) {
    this.parseArguments(args);
    const minLen = this.program.opts().minlen;
    const maxlen = this.program.opts().maxlen;
    const lacks = this.program.opts().lacks || [];
    const contains = this.program.opts().contains || [];

    // Only allocate the set of seen peptides when --unique is passed. Without it, this
    // command runs in constant memory no matter how large the input is, and we want to
    // keep it that way. Peptides are still written out as they are read, so --unique
    // does not delay the output either.
    const seen = this.program.opts().unique ? new Set<string>() : undefined;

    const input = new InputSource();
    const output = new OutputWriter(this.program.opts().output);

    try {
      for await (const line of input.lines([], this.program.opts().input)) {
        if (line.startsWith(">")) { // pass through FASTA headers
          output.line(line);
        } else if (Peptfilter.checkLength(line, minLen, maxlen) && Peptfilter.checkLacks(line, lacks) && Peptfilter.checkContains(line, contains)) {
          if (!seen?.has(line)) {
            seen?.add(line);
            output.line(line);
          }
        }
      }
    } catch (e) {
      this.program.error((e as Error).message);
    }

    await output.close();
  }

  static checkLength(line: string, minLen: number, maxlen: number): boolean {
    return line.length >= minLen && line.length <= maxlen;
  }

  static checkLacks(line: string, lacks: string[]): boolean {
    return lacks.every((aa: string) => !line.includes(aa));
  }

  static checkContains(line: string, contains: string[]): boolean {
    return contains.every((aa: string) => line.includes(aa));
  }
}
