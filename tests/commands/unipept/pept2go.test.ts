import { vi, afterAll } from 'vitest';
import { Pept2go } from "../../../lib/commands/unipept/pept2go.js";
import { setupPolly } from '../../mocks/polly.js';
import { Polly } from '@pollyjs/core';

let output: string[];
let polly: Polly;

vi
  .spyOn(process.stdout, "write")
  .mockImplementation((data: unknown) => { output.push(data as string); return true; });

beforeAll(() => {
  polly = setupPolly('pept2go');
});

afterAll(async () => {
  await polly.stop();
});

beforeEach(() => {
  output = [];
});

test('test with default args', async () => {
  const command = new Pept2go();
  await command.run(["AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("peptide,total_protein_count,go_term,go_protein_count")).toBeTruthy();
  expect(output[1].startsWith("AALTER,")).toBeTruthy();
  expect(output.length).toBeGreaterThanOrEqual(2);
});

test('test with fasta', async () => {
  const command = new Pept2go();
  await command.run([">test", "AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("fasta_header,peptide,total_protein_count,go_term,go_protein_count")).toBeTruthy();
  expect(output[1].startsWith(">test,AALTER,")).toBeTruthy();
  expect(output.length).toBeGreaterThanOrEqual(2);
});
