import { jest } from '@jest/globals';
import { Pept2interpro } from "../../../lib/commands/unipept/pept2interpro";

let output: string[];
jest
  .spyOn(process.stdout, "write")
  .mockImplementation((data: unknown) => { output.push(data as string); return true; });

beforeEach(() => {
  output = [];
});

test('test with default args', async () => {
  const command = new Pept2interpro();
  await command.run(["AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("peptide,total_protein_count,ipr_code,ipr_protein_count")).toBeTruthy();
  expect(output[1].startsWith("AALTER,3310,IPR003613")).toBeTruthy();
  expect(output.length).toBe(2);
});

test('test with fasta', async () => {
  const command = new Pept2interpro();
  await command.run([">test", "AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("fasta_header,peptide,total_protein_count,ipr_code,ipr_protein_count")).toBeTruthy();
  expect(output[1].startsWith(">test,AALTER,3310,IPR003613")).toBeTruthy();
  expect(output.length).toBe(2);
});
