import { vi } from 'vitest';
import { Pept2prot } from "../../../lib/commands/unipept/pept2prot";
import { setupMockFetch } from '../../mocks/mockFetch';

let output: string[];
vi
  .spyOn(process.stdout, "write")
  .mockImplementation((data: unknown) => { output.push(data as string); return true; });

beforeAll(() => {
  setupMockFetch();
});

beforeEach(() => {
  output = [];
});

test('test with default args', async () => {
  const command = new Pept2prot();
  await command.run(["AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("peptide,uniprot_id,protein_name,taxon_id,protein")).toBeTruthy();
  expect(output[1].startsWith("AALTER,")).toBeTruthy();
  expect(output.length).toBe(2);
});

test('test with fasta', async () => {
  const command = new Pept2prot();
  await command.run([">test", "AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("fasta_header,peptide,uniprot_id,protein_name,taxon_id,protein")).toBeTruthy();
  expect(output[1].startsWith(">test,AALTER,")).toBeTruthy();
  expect(output.length).toBe(2);
});
