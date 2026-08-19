import { Peptfilter } from '../../lib/commands/peptfilter.js';
import { vi } from 'vitest';
import * as mock from 'mock-stdin';

let output: string[];
let error: string[];
// eslint-disable-next-line @typescript-eslint/no-unused-vars
const writeSpy = vi
  .spyOn(process.stdout, "write")
  .mockImplementation((data: unknown) => { output.push(data as string); return true; });
const errorSpy = vi
  .spyOn(process.stderr, "write")
  .mockImplementation((data: unknown) => { error.push(data as string); return true; });

beforeEach(() => {
  output = [];
  error = [];
});

test('test length filter', async () => {
  // min length
  expect(Peptfilter.checkLength('AALER', 4, 10)).toBe(true);
  expect(Peptfilter.checkLength('AALER', 5, 10)).toBe(true);
  expect(Peptfilter.checkLength('AALER', 6, 10)).toBe(false);

  // max length
  expect(Peptfilter.checkLength('AALER', 1, 4)).toBe(false);
  expect(Peptfilter.checkLength('AALER', 1, 5)).toBe(true);
  expect(Peptfilter.checkLength('AALER', 1, 6)).toBe(true);
});

test('test lacks filter', async () => {
  expect(Peptfilter.checkLacks('AALER', ''.split(""))).toBe(true);
  expect(Peptfilter.checkLacks('AALER', 'BCD'.split(""))).toBe(true);
  expect(Peptfilter.checkLacks('AALER', 'A'.split(""))).toBe(false);
  expect(Peptfilter.checkLacks('AALER', 'AE'.split(""))).toBe(false);
});

test('test contains filter', async () => {
  expect(Peptfilter.checkContains('AALER', ''.split(""))).toBe(true);
  expect(Peptfilter.checkContains('AALER', 'A'.split(""))).toBe(true);
  expect(Peptfilter.checkContains('AALER', 'AE'.split(""))).toBe(true);
  expect(Peptfilter.checkContains('AALER', 'BCD'.split(""))).toBe(false);
  expect(Peptfilter.checkContains('AALER', 'AB'.split(""))).toBe(false);
});

test('test default filter from stdin', async () => {
  const stdin = mock.stdin();

  const command = new Peptfilter();
  const run = command.run();

  stdin.send("AAAA\n");
  stdin.send("AAAAA\n");
  stdin.end();

  await run;

  expect(errorSpy).toHaveBeenCalledTimes(0);
  expect(output.join("").trimEnd().split("\n").length).toBe(1);
});

test('test if it passes fasta from stdin', async () => {
  const stdin = mock.stdin();

  const command = new Peptfilter();
  const run = command.run();

  stdin.send(">AA\n");
  stdin.send("AAA\n");
  stdin.end();

  await run;

  expect(errorSpy).toHaveBeenCalledTimes(0);
  expect(output.join("").trimEnd().split("\n").length).toBe(1);
  expect(output[0]).toBe(">AA\n");
});

test('test complex example from stdin', async () => {
  const stdin = mock.stdin();

  const command = new Peptfilter();
  const run = command.run(["--minlen", "4", "--maxlen", "10", "--lacks", "B", "--contains", "A"]);

  stdin.send("A\n");
  stdin.send("AAAAAAAAAAA\n");
  stdin.send("AAAAB\n");
  stdin.send("BBBBB\n");
  stdin.send("CCCCC\n");
  stdin.send("CCCCCA\n");
  stdin.end();

  await run;

  expect(errorSpy).toHaveBeenCalledTimes(0);
  expect(output.join("").trimEnd().split("\n").length).toBe(1);
  expect(output[0]).toBe("CCCCCA\n");
});

test('test unique filter from stdin', async () => {
  const stdin = mock.stdin();

  const command = new Peptfilter();
  const run = command.run(["--unique"]);

  stdin.send("AALTER\n");
  stdin.send("AALTER\n");
  stdin.send("MLGIIR\n");
  stdin.send("AALTER\n");
  stdin.end();

  await run;

  expect(errorSpy).toHaveBeenCalledTimes(0);
  expect(output.join("").trimEnd().split("\n")).toStrictEqual(["AALTER", "MLGIIR"]);
});

test('test duplicates are kept without the unique filter', async () => {
  const stdin = mock.stdin();

  const command = new Peptfilter();
  const run = command.run();

  stdin.send("AALTER\n");
  stdin.send("AALTER\n");
  stdin.end();

  await run;

  expect(output.join("").trimEnd().split("\n")).toStrictEqual(["AALTER", "AALTER"]);
});

test('test unique deduplicates across fasta headers', async () => {
  const stdin = mock.stdin();

  const command = new Peptfilter();
  const run = command.run(["-u"]);

  stdin.send(">p1\n");
  stdin.send("AALTER\n");
  stdin.send("MLGIIR\n");
  stdin.send(">p2\n");
  stdin.send("AALTER\n");
  stdin.send("QWERTYK\n");
  stdin.end();

  await run;

  // headers always pass through, the peptides they bundle are deduplicated globally
  expect(output.join("").trimEnd().split("\n")).toStrictEqual([">p1", "AALTER", "MLGIIR", ">p2", "QWERTYK"]);
});

test('test unique combines with the other filters', async () => {
  const stdin = mock.stdin();

  const command = new Peptfilter();
  const run = command.run(["-u", "--minlen", "5", "--maxlen", "8"]);

  stdin.send("AALTER\n");
  stdin.send("AALTER\n");
  stdin.send("AA\n");
  stdin.send("QWERTYKLLL\n");
  stdin.end();

  await run;

  expect(output.join("").trimEnd().split("\n")).toStrictEqual(["AALTER"]);
});
