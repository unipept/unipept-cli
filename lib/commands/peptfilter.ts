import { createInterface } from 'node:readline';
import { BaseCommand } from './base_command.js';

export class Peptfilter extends BaseCommand {

  readonly description = `The peptfilter command filters a list of peptides according to specific criteria. The command expects a list of peptides that are passed to standard input.

The input should have one peptide per line. FASTA headers are preserved in the output, so that peptides remain bundled.`;

  constructor(options?: { exitOverride?: boolean, suppressOutput?: boolean, args?: string[] }) {
    super(options);

    this.program
      .summary("Filter peptides based on specific criteria.")
      .description(this.description)
      .option("--minlen <length>", "only retain peptides having at least this many amino acids", (d) => parseInt(d, 10), 5)
      .option("--maxlen <length>", "only retain peptides having at most this many amino acids", (d) => parseInt(d, 10), 50)
      .option("-l, --lacks <amino acids>", "only retain peptides that lack all of the specified amino acids", (d) => d.split(""))
      .option("-c, --contains <amino acids>", "only retain peptides that contain all of the specified amino acids", (d) => d.split(""));
  }

  /**
   * Performance note: this implementation takes 4 seconds to run on swissprot. It can be made faster by using line events instead of
   * async iterators. This alternative implementation runs in 2.5 seconds. However, I decided that the async iterator implementation is
   * both more readable and more in line with the implementation of the other commands.
   */
  async run() {
    this.parseArguments();
    const minLen = this.program.opts().minlen;
    const maxlen = this.program.opts().maxlen;
    const lacks = this.program.opts().lacks || [];
    const contains = this.program.opts().contains || [];

    let output = [];
    let i = 0;

    for await (const line of createInterface({ input: process.stdin })) {
      i++;
      if (line.startsWith(">")) {
        output.push(line);
      } else if (Peptfilter.checkLength(line, minLen, maxlen) && Peptfilter.checkLacks(line, lacks) && Peptfilter.checkContains(line, contains)) {
        output.push(line);
      }
      if (i % 1000 === 0) {
        output.push("");
        process.stdout.write(output.join("\n"));
        output = [];
      }
    }

    output.push("");
    process.stdout.write(output.join("\n"));
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
