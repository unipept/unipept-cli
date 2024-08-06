import { jest } from '@jest/globals';
import { Pept2lca } from "../../../lib/commands/unipept/pept2lca";

let output: string[];
const writeSpy = jest
  .spyOn(process.stdout, "write")
  .mockImplementation((data: unknown) => { output.push(data as string); return true; });

beforeEach(() => {
  output = [];
});

test('test with default args', async () => {
  const command = new Pept2lca();
  await command.run(["AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("peptide,taxon_id")).toBeTruthy();
  expect(output[1].startsWith("AALTER,1,root,no rank")).toBeTruthy();
  expect(output.length).toBe(2);
});

test('test with fasta', async () => {
  const command = new Pept2lca();
  await command.run([">test", "AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("fasta_header,peptide,taxon_id")).toBeTruthy();
  expect(output[1].startsWith(">test,AALTER,1,root,no rank")).toBeTruthy();
  expect(output.length).toBe(2);
});
