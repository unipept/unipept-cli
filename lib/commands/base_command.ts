import { Command } from "commander";
import { collect } from "../io/input.js";
import { version } from "../version.js";

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
    this.version = version;
    this.program = this.create(options);
  }

  abstract run(args?: string[]): void;

  /**
   * Registers the input and output options that every command shares. Commands that read
   * their input from somewhere call this from their constructor.
   */
  protected addIoOptions(): void {
    this.program
      .option("-i, --input <file>", "read input from file, may be used more than once", collect)
      .option("-o, --output <file>", "write output to file");
  }

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
