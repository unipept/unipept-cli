import { jest } from '@jest/globals';
import { Peptinfo } from "../../../lib/commands/unipept/peptinfo";
import { setupMockFetch } from '../../mocks/mockFetch';

let output: string[];
jest
  .spyOn(process.stdout, "write")
  .mockImplementation((data: unknown) => { output.push(data as string); return true; });

beforeAll(() => {
  setupMockFetch();
});

beforeEach(() => {
  output = [];
});

test('test with default args', async () => {
  const command = new Peptinfo();
  await command.run(["AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("peptide,total_protein_count,taxon_id,taxon_name,taxon_rank,ec_number,ec_protein_count,go_term,go_protein_count,ipr_code,ipr_protein_count")).toBeTruthy();
  expect(output[1].startsWith("AALTER,")).toBeTruthy();
  expect(output[1].includes(",1,root,")).toBeTruthy();
  expect(output.length).toBe(2);
});

test('test with fasta', async () => {
  const command = new Peptinfo();
  await command.run([">test", "AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("fasta_header,peptide,total_protein_count,taxon_id,taxon_name,taxon_rank,ec_number,ec_protein_count,go_term,go_protein_count,ipr_code,ipr_protein_count")).toBeTruthy();
  expect(output[1].startsWith(">test,AALTER,")).toBeTruthy();
  expect(output[1].includes(",1,root")).toBeTruthy();
  expect(output.length).toBe(2);
});
