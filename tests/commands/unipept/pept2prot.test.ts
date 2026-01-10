import { vi, afterAll } from 'vitest';
import { Pept2prot } from "../../../lib/commands/unipept/pept2prot.js";
import { setupPolly } from '../../mocks/polly.js';
import { Polly } from '@pollyjs/core';

let output: string[];
let polly: Polly;

vi
  .spyOn(process.stdout, "write")
  .mockImplementation((data: unknown) => { output.push(data as string); return true; });

beforeAll(() => {
  polly = setupPolly('pept2prot');
});

afterAll(async () => {
  await polly.stop();
});

beforeEach(() => {
  output = [];
});

test('test with default args', async () => {
  const command = new Pept2prot();
  await command.run(["AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("peptide,uniprot_id,protein_name,taxon_id,protein")).toBeTruthy();
  expect(output[1].startsWith("AALTER,")).toBeTruthy();
  // Ensure we got some protein data (not just empty commas)
  expect(output[1].length).toBeGreaterThan(10);
  expect(output.length).toBeGreaterThanOrEqual(2);
});

test('test with fasta', async () => {
  const command = new Pept2prot();
  await command.run([">test", "AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("fasta_header,peptide,uniprot_id,protein_name,taxon_id,protein")).toBeTruthy();
  expect(output[1].startsWith(">test,AALTER,")).toBeTruthy();
  expect(output[1].length).toBeGreaterThan(10);
  expect(output.length).toBeGreaterThanOrEqual(2);
});
