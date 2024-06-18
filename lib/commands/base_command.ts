import { Command } from "commander";
import { version } from '../../package.json';

export abstract class BaseCommand {
  public program: Command;

  constructor(options?: { exitOverride?: boolean, suppressOutput?: boolean }) {
    this.program = this.create(options);
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
}
