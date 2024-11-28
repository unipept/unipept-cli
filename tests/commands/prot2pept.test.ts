import { Prot2pept } from '../../lib/commands/prot2pept';
import { jest } from '@jest/globals';
import * as mock from 'mock-stdin';

let output: string[];
let error: string[];
// eslint-disable-next-line @typescript-eslint/no-unused-vars
const writeSpy = jest
  .spyOn(process.stdout, "write")
  .mockImplementation((data: unknown) => { output.push(data as string); return true; });
const errorSpy = jest
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
