import { jest } from '@jest/globals';
import { Pept2prot } from "../../../lib/commands/unipept/pept2prot";

let output: string[];
jest
  .spyOn(process.stdout, "write")
  .mockImplementation((data: unknown) => { output.push(data as string); return true; });

beforeEach(() => {
  output = [];
});

test('test with default args', async () => {
  const command = new Pept2prot();
  await command.run(["AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("peptide,uniprot_id,protein_name,taxon_id,protein")).toBeTruthy();
  expect(output[1].startsWith("AALTER,P78330")).toBeTruthy();
  expect(output.length).toBe(2);
});

test('test with fasta', async () => {
  const command = new Pept2prot();
  await command.run([">test", "AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("fasta_header,peptide,uniprot_id,protein_name,taxon_id,protein")).toBeTruthy();
  expect(output[1].startsWith(">test,AALTER,P78330")).toBeTruthy();
  expect(output.length).toBe(2);
});
