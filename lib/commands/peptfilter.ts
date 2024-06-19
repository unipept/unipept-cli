import { Option } from 'commander';
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

  async run() {
    this.parseArguments();
    console.log(this.program.opts())
    const minLen = this.program.opts().minLen;
    const maxlen = this.program.opts().maxLen;
    const lacks = this.program.opts().lacks || [];
    const contains = this.program.opts().contains || [];

    for await (const line of createInterface({ input: process.stdin })) {
      if (line.startsWith(">")) {
        process.stdout.write(line + "\n");
        continue;
      }
      if (Peptfilter.checkLength(line, minLen, maxlen) && Peptfilter.checkLacks(line, lacks) && Peptfilter.checkContains(line, contains)) {
        process.stdout.write(line + "\n");
      }
    }
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
