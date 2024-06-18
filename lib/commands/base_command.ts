import { Command } from "commander";
import { version } from '../../package.json';

export abstract class BaseCommand {
  public program: Command;
  args: string[] | undefined;

  constructor(options?: { exitOverride?: boolean, suppressOutput?: boolean, args?: string[] }) {
    this.program = this.create(options);
    this.args = options?.args;
  }

  abstract run(): void;

  create(options?: { exitOverride?: boolean, suppressOutput?: boolean }): Command {
    const program = new Command();

    // used for debugging
    if (options?.exitOverride) {
      program.exitOverride();  // don't exit on error
    }
    if (options?.suppressOutput) {
      program.configureOutput({
        writeOut: () => { },
        writeErr: () => { }
      });
    }

    program.version(version);

    return program;
  }

  parseArguments() {
    if (this.args) {
      // custom arg parsing to be able to inject args for testing
      this.program.parse(this.args, { from: "user" });
    } else {
      this.program.parse();
    }
  }
}
