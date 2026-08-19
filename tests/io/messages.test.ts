import { afterEach, expect, test, vi } from 'vitest';
import { existsSync, mkdtempSync, readFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { Messages } from '../../lib/io/messages.js';

const tmp = () => path.join(mkdtempSync(path.join(tmpdir(), 'unipept-log-')), 'messages.log');

afterEach(() => {
  vi.restoreAllMocks();
});

test('test messages go to standard error by default', async () => {
  const errors: string[] = [];
  vi.spyOn(process.stderr, 'write').mockImplementation((chunk: unknown) => { errors.push(chunk as string); return true; });

  const messages = new Messages();
  expect(messages.logging).toBe(false);
  await messages.report("something happened");

  expect(errors).toStrictEqual(["something happened\n"]);
});

test('test messages go to the log file when one is given', async () => {
  const file = tmp();
  const errors: string[] = [];
  vi.spyOn(process.stderr, 'write').mockImplementation((chunk: unknown) => { errors.push(chunk as string); return true; });

  const messages = new Messages(file);
  expect(messages.logging).toBe(true);
  expect(messages.file).toBe(file);
  await messages.report("first");
  await messages.report("second");

  expect(errors).toStrictEqual([]);
  expect(readFileSync(file, "utf8")).toBe("first\nsecond\n");
});

test('test quiet drops messages entirely', async () => {
  const file = tmp();
  const errors: string[] = [];
  vi.spyOn(process.stderr, 'write').mockImplementation((chunk: unknown) => { errors.push(chunk as string); return true; });

  await new Messages(undefined, true).report("to stderr");
  await new Messages(file, true).report("to file");

  expect(errors).toStrictEqual([]);
  expect(existsSync(file)).toBe(false);
});
