import { Uniprot } from '../../lib/commands/uniprot';
import { vi } from 'vitest';
import * as mock from 'mock-stdin';

let output: string[];
let error: string[];
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

test('test single argument', async () => {
  const command = new Uniprot();
  await command.run(["Q6GZX3"]);

  expect(writeSpy).toHaveBeenCalledTimes(1);
  expect(errorSpy).toHaveBeenCalledTimes(0);
  expect(output.length).toBe(1);
});

test('test two arguments', async () => {
  const command = new Uniprot();
  await command.run(["Q6GZX3", "Q6GZX4"]);

  expect(writeSpy).toHaveBeenCalledTimes(2);
  expect(errorSpy).toHaveBeenCalledTimes(0);
  expect(output.length).toBe(2);
});

test('test fasta output', async () => {
  const command = new Uniprot();
  await command.run(["--format", "fasta", "Q6GZX3", "Q6GZX4"]);

  expect(writeSpy).toHaveBeenCalledTimes(2);
  expect(errorSpy).toHaveBeenCalledTimes(0);
  expect(output.length).toBe(2);
  expect(output[0].startsWith(">")).toBe(true);
});

test('test single line stdin', async () => {
  const stdin = mock.stdin();

  const command = new Uniprot();
  const run = command.run();

  stdin.send("Q6GZX3\n");
  stdin.end();

  await run;

  expect(writeSpy).toHaveBeenCalledTimes(1);
  expect(errorSpy).toHaveBeenCalledTimes(0);
  expect(output.length).toBe(1);
});

test('test double line stdin', async () => {
  const stdin = mock.stdin();

  const command = new Uniprot();
  const run = command.run();

  stdin.send("Q6GZX3\n");
  stdin.send("Q6GZX4\n");
  stdin.end();

  await run;

  expect(writeSpy).toHaveBeenCalledTimes(2);
  expect(errorSpy).toHaveBeenCalledTimes(0);
  expect(output.length).toBe(2);
});

test('test on invalid id', async () => {
  const command = new Uniprot();
  await command.run(["Bart"]);

  expect(errorSpy).toHaveBeenCalledTimes(1);
});

test('test all valid formats', async () => {
  for (const format of Uniprot.VALID_FORMATS) {
    const command = new Uniprot();
    await command.run(["--format", format, "Q6GZX3"]);

    expect(errorSpy).toHaveBeenCalledTimes(0);
  }
});
