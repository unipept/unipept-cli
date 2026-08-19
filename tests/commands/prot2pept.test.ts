import { Prot2pept } from '../../lib/commands/prot2pept.js';
import { vi } from 'vitest';
import * as mock from 'mock-stdin';
import { mkdtempSync, readFileSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';

const tmpFile = (name: string, ...lines: string[]) => {
  const file = path.join(mkdtempSync(path.join(tmpdir(), 'unipept-prot2pept-')), name);
  writeFileSync(file, lines.join("\n") + "\n");
  return file;
};

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

test('test single line input 1', async () => {
  const stdin = mock.stdin();

  const command = new Prot2pept();
  const run = command.run();

  stdin.send("AALTERAALTERPAALTER\n");
  stdin.end();

  await run;

  expect(errorSpy).toHaveBeenCalledTimes(0);
  expect(output.join("").trimEnd()).toBe("AALTER\nAALTERPAALTER");
});

test('test single line input 2', async () => {
  const stdin = mock.stdin();

  const command = new Prot2pept();
  const run = command.run();

  stdin.send("KRKPR\n");
  stdin.end();

  await run;

  expect(errorSpy).toHaveBeenCalledTimes(0);
  expect(output.join("").trimEnd()).toBe("K\nR\nKPR");
});

test('test multi line input', async () => {
  const stdin = mock.stdin();

  const command = new Prot2pept();
  const run = command.run();

  stdin.send("AALTERAALTERPAALTER\n");
  stdin.send("AALTERAA\n");
  stdin.end();

  await run;

  expect(errorSpy).toHaveBeenCalledTimes(0);
  expect(output.join("").trimEnd()).toBe("AALTER\nAALTERPAALTER\nAALTER\nAA");
});

test('test fasta input 1', async () => {
  const stdin = mock.stdin();

  const command = new Prot2pept();
  const run = command.run();

  stdin.send(">AKA\nAALTERAALTERPAALTER\n");
  stdin.end();

  await run;

  expect(errorSpy).toHaveBeenCalledTimes(0);
  expect(output.join("").trimEnd()).toBe(">AKA\nAALTER\nAALTERPAALTER");
});

test('test fasta input 2', async () => {
  const stdin = mock.stdin();

  const command = new Prot2pept();
  const run = command.run();

  stdin.send(">AKA\nAAL\nT\nERAALTER\nP\nAALTER\n");
  stdin.end();

  await run;

  expect(errorSpy).toHaveBeenCalledTimes(0);
  expect(output.join("").trimEnd()).toBe(">AKA\nAALTER\nAALTERPAALTER");
});

test('test fasta input 3', async () => {
  const stdin = mock.stdin();

  const command = new Prot2pept();
  const run = command.run();

  stdin.send(">AKA\nAAL\nT\n>\nERAALTER\nP\nAALTER");
  stdin.end();

  await run;

  expect(errorSpy).toHaveBeenCalledTimes(0);
  expect(output.join("").trimEnd()).toBe(">AKA\nAALT\n>\nER\nAALTERPAALTER");
});

test('test custom pattern', async () => {
  const stdin = mock.stdin();

  const command = new Prot2pept();
  const run = command.run(["--pattern", "([KR])([^A])"]);

  stdin.send("AALTERAALTERPAALTER\n");
  stdin.end();

  await run;

  expect(errorSpy).toHaveBeenCalledTimes(0);
  expect(output.join("").trimEnd()).toBe("AALTERAALTER\nPAALTER");
});

test('test reading from an input file and writing to an output file', async () => {
  const target = tmpFile("out.txt");
  const command = new Prot2pept();
  await command.run(["-i", tmpFile("in.txt", "AALTERSVKAAPKR"), "-o", target]);

  expect(output).toStrictEqual([]);
  expect(readFileSync(target, "utf8")).toBe("AALTER\nSVK\nAAPK\nR\n");
});

test('test fasta spanning several input files', async () => {
  const command = new Prot2pept();
  await command.run(["-i", tmpFile("a.fa", ">one", "AALTERSVK"), "-i", tmpFile("b.fa", ">two", "AAPKR")]);

  expect(output.join("").trimEnd().split("\n")).toStrictEqual([">one", "AALTER", "SVK", ">two", "AAPK", "R"]);
});
