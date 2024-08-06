import { jest } from '@jest/globals';
import { Taxonomy } from "../../../lib/commands/unipept/taxonomy";

let output: string[];
jest
  .spyOn(process.stdout, "write")
  .mockImplementation((data: unknown) => { output.push(data as string); return true; });

beforeEach(() => {
  output = [];
});

test('test with default args', async () => {
  const command = new Taxonomy();
  await command.run(["216816"], { header: true, format: "csv" });
  expect(output[0].startsWith("taxon_id,taxon_name,taxon_rank")).toBeTruthy();
  expect(output[1].startsWith("216816,Bifidobacterium longum,species")).toBeTruthy();
  expect(output.length).toBe(2);
});

test('test with fasta', async () => {
  const command = new Taxonomy();
  await command.run([">test", "216816"], { header: true, format: "csv" });
  expect(output[0].startsWith("fasta_header,taxon_id,taxon_name,taxon_rank")).toBeTruthy();
  expect(output[1].startsWith(">test,216816,Bifidobacterium longum,species")).toBeTruthy();
  expect(output.length).toBe(2);
});
