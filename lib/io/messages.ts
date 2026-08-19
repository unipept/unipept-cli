import { appendFile, mkdir } from "node:fs/promises";
import path from "node:path";

/**
 * Reports the messages that a command would normally write to standard error.
 *
 * With --log they are appended to the given file instead, and with --quiet they are
 * dropped altogether.
 */
export class Messages {
  constructor(private readonly logFile?: string, private readonly quiet = false) { }

  /** Whether messages end up in a file rather than on standard error. */
  get logging(): boolean {
    return this.logFile !== undefined;
  }

  /** The file messages are appended to, if any. */
  get file(): string | undefined {
    return this.logFile;
  }

  /** Reports a single message, which does not need to end in a newline. */
  async report(message: string): Promise<void> {
    if (this.quiet) return;

    if (this.logFile !== undefined) {
      await Messages.append(this.logFile, message);
    } else {
      process.stderr.write(`${message}\n`);
    }
  }

  /** Appends a message to a file, creating the directory it lives in when needed. */
  static async append(file: string, message: string): Promise<void> {
    await mkdir(path.dirname(path.resolve(file)), { recursive: true });
    await appendFile(file, `${message}\n`);
  }
}
