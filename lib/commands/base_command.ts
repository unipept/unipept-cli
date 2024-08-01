import { Command } from "commander";
import { readFileSync } from "fs";

/**
 * This is a base class which provides a common interface for all commands.
 * This is mostly used for testing purposes.
 *
 * Commands implementing this class should override the run method and call parseArguments
 * at the beginning of the run method.
 */
export abstract class BaseCommand {
  public program: Command;
  version: string;

  constructor(options?: { exitOverride?: boolean, suppressOutput?: boolean }) {
    this.version = JSON.parse(readFileSync(new URL("../../package.json", import.meta.url), "utf8")).version;
    this.program = this.create(options);
  }

  abstract run(args?: string[]): void;

  /**
   * Create sets up the command line program. Implementing classes can add additional options.
   * to this.program.
   */
  create(options?: { exitOverride?: boolean, suppressOutput?: boolean }): Command {
    const program = new Command();

    // used for debugging
    if (options?.exitOverride) {
      program.exitOverride();  // don't exit on error
    }
    if (options?.suppressOutput) {
      // don't write anything to the console
      program.configureOutput({
        writeOut: () => { },
        writeErr: () => { }
      });
    }
    program.version(this.version);

    return program;
  }

  /**
   * This allows us to pass a custom list of strings as arguments to the command during testing.
   */
  parseArguments(args?: string[]) {
    if (args) {
      // custom arg parsing to be able to inject args for testing
      this.program.parse(args, { from: "user" });
    } else {
      this.program.parse();
    }
  }
}
