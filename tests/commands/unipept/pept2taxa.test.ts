import { jest } from '@jest/globals';
import { Pept2taxa } from "../../../lib/commands/unipept/pept2taxa";

let output: string[];
jest
  .spyOn(process.stdout, "write")
  .mockImplementation((data: unknown) => { output.push(data as string); return true; });

beforeEach(() => {
  output = [];
});

test('test with default args', async () => {
  const command = new Pept2taxa();
  await command.run(["AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("peptide,taxon_id,taxon_name,taxon_rank")).toBeTruthy();
  expect(output[1].startsWith("AALTER,41,Stigmatella aurantiaca,species")).toBeTruthy();
  expect(output.length).toBe(2);
});

test('test with fasta', async () => {
  const command = new Pept2taxa();
  await command.run([">test", "AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("fasta_header,peptide,taxon_id,taxon_name,taxon_rank")).toBeTruthy();
  expect(output[1].startsWith(">test,AALTER,41,Stigmatella aurantiaca,species")).toBeTruthy();
  expect(output.length).toBe(2);
});
