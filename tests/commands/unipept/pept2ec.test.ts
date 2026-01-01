import { vi } from 'vitest';
import { Pept2ec } from "../../../lib/commands/unipept/pept2ec";
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
  const command = new Pept2ec();
  await command.run(["AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("peptide,total_protein_count,ec_number,ec_protein_count")).toBeTruthy();
  expect(output[1].startsWith("AALTER,")).toBeTruthy();
  expect(output[1].includes("2.3.2.27")).toBeTruthy();
  expect(output.length).toBe(2);
});

test('test with fasta', async () => {
  const command = new Pept2ec();
  await command.run([">test", "AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("fasta_header,peptide,total_protein_count,ec_number,ec_protein_count")).toBeTruthy();
  expect(output[1].startsWith(">test,AALTER,")).toBeTruthy();
  expect(output[1].includes("2.3.2.27")).toBeTruthy();
  expect(output.length).toBe(2);
});
