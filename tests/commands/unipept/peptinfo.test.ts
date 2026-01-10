import { vi, afterAll } from 'vitest';
import { Peptinfo } from "../../../lib/commands/unipept/peptinfo";
import { setupPolly } from '../../mocks/polly';
import { Polly } from '@pollyjs/core';

let output: string[];
let polly: Polly;

vi
  .spyOn(process.stdout, "write")
  .mockImplementation((data: unknown) => { output.push(data as string); return true; });

beforeAll(() => {
  polly = setupPolly('peptinfo');
});

afterAll(async () => {
  await polly.stop();
});

beforeEach(() => {
  output = [];
});

test('test with default args', async () => {
  const command = new Peptinfo();
  await command.run(["AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("peptide,total_protein_count,taxon_id,taxon_name,taxon_rank,ec_number,ec_protein_count,go_term,go_protein_count,ipr_code,ipr_protein_count")).toBeTruthy();
  expect(output[1].startsWith("AALTER,")).toBeTruthy();
  // We check that we got some results (2 lines: header + content)
  expect(output.length).toBeGreaterThanOrEqual(2);
});

test('test with fasta', async () => {
  const command = new Peptinfo();
  await command.run([">test", "AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("fasta_header,peptide,total_protein_count,taxon_id,taxon_name,taxon_rank,ec_number,ec_protein_count,go_term,go_protein_count,ipr_code,ipr_protein_count")).toBeTruthy();
  expect(output[1].startsWith(">test,AALTER,")).toBeTruthy();
  expect(output.length).toBeGreaterThanOrEqual(2);
});
