import { vi, afterAll } from 'vitest';
import { Taxonomy } from "../../../lib/commands/unipept/taxonomy";
import { setupPolly } from '../../mocks/polly';
import { Polly } from '@pollyjs/core';

let output: string[];
let polly: Polly;

vi
  .spyOn(process.stdout, "write")
  .mockImplementation((data: unknown) => { output.push(data as string); return true; });

beforeAll(() => {
  polly = setupPolly('taxonomy');
});

afterAll(async () => {
  await polly.stop();
});

beforeEach(() => {
  output = [];
});

test('test with default args', async () => {
  const command = new Taxonomy();
  await command.run(["216816"], { header: true, format: "csv" });
  expect(output[0].startsWith("taxon_id,taxon_name,taxon_rank")).toBeTruthy();
  expect(output[1].startsWith("216816,Bifidobacterium longum,species")).toBeTruthy();
  expect(output.length).toBeGreaterThanOrEqual(2);
});

test('test with fasta', async () => {
  const command = new Taxonomy();
  await command.run([">test", "216816"], { header: true, format: "csv" });
  expect(output[0].startsWith("fasta_header,taxon_id,taxon_name,taxon_rank")).toBeTruthy();
  expect(output[1].startsWith(">test,216816,Bifidobacterium longum,species")).toBeTruthy();
  expect(output.length).toBeGreaterThanOrEqual(2);
});
