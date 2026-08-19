import { vi, afterAll } from 'vitest';
import { Pept2lca } from "../../../lib/commands/unipept/pept2lca.js";
import { setupPolly } from '../../mocks/polly.js';
import { Polly } from '@pollyjs/core';

let output: string[];
let polly: Polly;

vi
  .spyOn(process.stdout, "write")
  .mockImplementation((data: unknown) => { output.push(data as string); return true; });

beforeAll(() => {
  polly = setupPolly('pept2lca');
});

afterAll(async () => {
  await polly.stop();
});

beforeEach(() => {
  output = [];
});

test('test with default args', async () => {
  const command = new Pept2lca();
  await command.run(["AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("peptide,cutoff_used,taxon_id")).toBeTruthy();
  expect(output[1].startsWith("AALTER,1,1,root,no rank")).toBeTruthy();
  expect(output.length).toBeGreaterThanOrEqual(2);
});

test('test with fasta', async () => {
  const command = new Pept2lca();
  await command.run([">test", "AALTER"], { header: true, format: "csv" });
  expect(output[0].startsWith("fasta_header,peptide,cutoff_used,taxon_id")).toBeTruthy();
  expect(output[1].startsWith(">test,AALTER,1,1,root,no rank")).toBeTruthy();
  expect(output.length).toBeGreaterThanOrEqual(2);
});

test('test json output is wrapped and parseable', async () => {
  const command = new Pept2lca();
  await command.run(["AALTER"], { header: true, format: "json" });

  const json = output.join("").trim();
  expect(json.startsWith("[")).toBeTruthy();
  expect(json.endsWith("]")).toBeTruthy();
  expect(JSON.parse(json).length).toBe(1);
});

test('test xml output is wrapped', async () => {
  const command = new Pept2lca();
  await command.run(["AALTER"], { header: true, format: "xml" });

  const xml = output.join("").trim();
  expect(xml.startsWith("<results>")).toBeTruthy();
  expect(xml.endsWith("</results>")).toBeTruthy();
});
