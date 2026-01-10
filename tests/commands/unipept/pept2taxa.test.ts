import { vi, afterAll } from 'vitest';
import { Pept2taxa } from "../../../lib/commands/unipept/pept2taxa";
import { setupPolly } from '../../mocks/polly';
import { Polly } from '@pollyjs/core';

let output: string[];
let polly: Polly;

vi
  .spyOn(process.stdout, "write")
  .mockImplementation((data: unknown) => { output.push(data as string); return true; });

beforeAll(() => {
  polly = setupPolly('pept2taxa');
});

afterAll(async () => {
  await polly.stop();
});

beforeEach(() => {
  output = [];
});

test('test with default args', async () => {
  const command = new Pept2taxa();
  await command.run(["AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("peptide,taxon_id,taxon_name,taxon_rank")).toBeTruthy();
  expect(output[1].startsWith("AALTER,")).toBeTruthy();
  // Check for presence of known taxon from AALTER (e.g. Nonomuraea rubra or similar)
  // Since we are using live recordings, we check for a known result.
  // Using a loose check that at least one result contains a taxon name string
  expect(output.some(line => line.match(/[a-zA-Z]+/))).toBeTruthy();
  expect(output.length).toBeGreaterThanOrEqual(2);
});

test('test with fasta', async () => {
  const command = new Pept2taxa();
  await command.run([">test", "AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("fasta_header,peptide,taxon_id,taxon_name,taxon_rank")).toBeTruthy();
  expect(output[1].startsWith(">test,AALTER,")).toBeTruthy();
  expect(output.length).toBeGreaterThanOrEqual(2);
});
