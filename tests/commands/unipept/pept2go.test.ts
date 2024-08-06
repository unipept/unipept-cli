import { jest } from '@jest/globals';
import { Pept2go } from "../../../lib/commands/unipept/pept2go";

let output: string[];
jest
  .spyOn(process.stdout, "write")
  .mockImplementation((data: unknown) => { output.push(data as string); return true; });

beforeEach(() => {
  output = [];
});

test('test with default args', async () => {
  const command = new Pept2go();
  await command.run(["AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("peptide,total_protein_count,go_term,go_protein_count")).toBeTruthy();
  expect(output[1].startsWith("AALTER,3310,GO:0003677")).toBeTruthy();
  expect(output.length).toBe(2);
});

test('test with fasta', async () => {
  const command = new Pept2go();
  await command.run([">test", "AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("fasta_header,peptide,total_protein_count,go_term,go_protein_count")).toBeTruthy();
  expect(output[1].startsWith(">test,AALTER,3310,GO:0003677")).toBeTruthy();
  expect(output.length).toBe(2);
});
