import { constants, createReadStream } from "node:fs";
import { access } from "node:fs/promises";
import { createInterface, Interface } from "node:readline";

/**
 * Resolves where a command reads its input from, and hands it back as a single stream
 * of lines. The precedence is the same for every command:
 *
 * - command line arguments
 * - input files, read one after the other
 * - standard input
 *
 * Only the first of these that is present is used.
 */
export class InputSource {
  // we must keep a handle on this to be able to close it properly in tests
  streamInterface?: Interface;

  /**
   * @param args positional arguments given to the command
   * @param input the value of the repeatable --input option, if any
   */
  lines(args: string[], input?: string | string[]): IterableIterator<string> | AsyncIterableIterator<string> {
    const files = input === undefined ? [] : [input].flat();

    if (args.length > 0) {
      return args.values();
    } else if (files.length > 0) {
      return this.readFiles(files);
    } else {
      if (process.stdin.isTTY) {
        const eofKey = process.platform === "win32" ? "Ctrl+Z, Enter" : "Ctrl+D";
        process.stderr.write(`Reading from standard input... (Press ${eofKey} to finish)\n`);
      }
      this.streamInterface = createInterface({ input: process.stdin });
      return this.streamInterface[Symbol.asyncIterator]();
    }
  }

  /**
   * Reads the given files one after the other, as a single stream of lines.
   *
   * The files are opened one at a time and only while they are being read, so that reading
   * many or large files does not depend on how many of them there are.
   */
  private async *readFiles(files: string[]): AsyncIterableIterator<string> {
    // check every file up front, so that a missing file halfway through the list is
    // reported before any of the earlier files have produced output
    for (const file of files) {
      await InputSource.assertReadable(file);
    }

    for (const file of files) {
      const stream = createReadStream(file);
      const streamInterface = createInterface({ input: stream });
      this.streamInterface = streamInterface;

      try {
        yield* streamInterface;
      } finally {
        streamInterface.close();
        stream.destroy();
        if (this.streamInterface === streamInterface) {
          this.streamInterface = undefined;
        }
      }
    }
  }

  /**
   * Throws an error naming the file when it cannot be read, instead of letting a bare
   * errno bubble up from the read stream.
   */
  private static async assertReadable(file: string): Promise<void> {
    try {
      await access(file, constants.R_OK);
    } catch (e) {
      const code = (e as NodeJS.ErrnoException).code;
      const reason = code === "ENOENT" ? "no such file or directory"
        : code === "EACCES" ? "permission denied"
          : code;
      throw new Error(`Unable to read input file '${file}': ${reason}`, { cause: e });
    }
  }
}

/**
 * Gathers repeated options into a list, so that --input can be passed more than once.
 */
export function collect(value: string, previous?: string[]): string[] {
  return (previous ?? []).concat([value]);
}
