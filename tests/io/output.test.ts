import { afterEach, expect, test, vi } from 'vitest';
import { mkdtempSync, readFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { OutputWriter } from '../../lib/io/output.js';

const tmp = () => path.join(mkdtempSync(path.join(tmpdir(), 'unipept-out-')), 'out.txt');

let written: string[] = [];
const captureStdout = () => {
  written = [];
  vi.spyOn(process.stdout, 'write').mockImplementation((chunk: unknown) => { written.push(chunk as string); return true; });
};

afterEach(() => {
  vi.restoreAllMocks();
});

test('test lines are buffered until the buffer is full', async () => {
  captureStdout();
  const output = new OutputWriter();

  for (let i = 0; i < OutputWriter.BUFFER_SIZE - 1; i++) {
    output.line(`line${i}`);
  }
  expect(written).toStrictEqual([]);

  output.line("last");
  expect(written.length).toBe(1);
  expect(written[0].startsWith("line0\nline1\n")).toBe(true);
  expect(written[0].endsWith("last\n")).toBe(true);
});

test('test close flushes what is left', async () => {
  captureStdout();
  const output = new OutputWriter();

  output.line("a");
  output.line("b");
  expect(written).toStrictEqual([]);

  await output.close();
  expect(written).toStrictEqual(["a\nb\n"]);
});

test('test close writes nothing when there was no output', async () => {
  captureStdout();
  const output = new OutputWriter();

  await output.close();
  expect(written).toStrictEqual([]);
});

test('test write goes out after anything still queued', async () => {
  captureStdout();
  const output = new OutputWriter();

  output.line("queued");
  output.write("immediate");

  expect(written).toStrictEqual(["queued\n", "immediate"]);
});

test('test output can be written to a file', async () => {
  const file = tmp();
  const output = new OutputWriter(file);

  output.line("first");
  output.line("second");
  await output.close();

  expect(readFileSync(file, "utf8")).toBe("first\nsecond\n");
});
