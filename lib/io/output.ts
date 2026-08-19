import { createWriteStream, WriteStream } from "node:fs";

/**
 * Writes the output of a command, either to a file given with --output or to standard output.
 *
 * Lines are buffered before being written, which makes a large difference in performance, but
 * they are still handed to the stream while the input is being read rather than at the end.
 */
export class OutputWriter {
  /** How many lines to gather before writing them out in one go. */
  static readonly BUFFER_SIZE = 1000;

  private readonly stream: NodeJS.WritableStream;
  private readonly file: boolean;
  private buffer: string[] = [];

  constructor(output?: string) {
    this.file = output !== undefined;
    if (output !== undefined) {
      this.stream = createWriteStream(output);
    } else {
      this.stream = process.stdout;
      handleBrokenPipe();
    }
  }

  /** Queues a single line, flushing once enough of them have piled up. */
  line(text: string): void {
    this.buffer.push(text);
    if (this.buffer.length >= OutputWriter.BUFFER_SIZE) {
      this.flush();
    }
  }

  /** Writes a chunk as is, after anything still queued, for output that is not line shaped. */
  write(text: string): void {
    this.flush();
    this.stream.write(text);
  }

  private flush(): void {
    if (this.buffer.length === 0) return;
    // an empty entry adds the trailing newline without copying the whole buffer again
    this.buffer.push("");
    this.stream.write(this.buffer.join("\n"));
    this.buffer = [];
  }

  /** Flushes whatever is left and closes the file, if we are writing to one. */
  async close(): Promise<void> {
    this.flush();
    if (this.file) {
      await new Promise<void>(resolve => (this.stream as WriteStream).end(resolve));
    }
  }
}

let brokenPipeHandled = false;

/**
 * Exits quietly when the command we are piped into stops reading, as `head` does.
 * Without this, node turns the EPIPE into an unhandled error event and prints a stack trace.
 */
function handleBrokenPipe(): void {
  if (brokenPipeHandled) return;
  brokenPipeHandled = true;

  process.stdout.on("error", (err) => {
    if ((err as NodeJS.ErrnoException).code === "EPIPE") {
      process.exit(0);
    }
  });
}
