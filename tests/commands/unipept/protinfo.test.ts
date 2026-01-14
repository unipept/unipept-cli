import { vi, afterAll } from 'vitest';
import { Protinfo } from "../../../lib/commands/unipept/protinfo.js";
import { setupPolly } from '../../mocks/polly.js';
import { Polly } from '@pollyjs/core';

let output: string[];
let polly: Polly;

vi
  .spyOn(process.stdout, "write")
  .mockImplementation((data: unknown) => { output.push(data as string); return true; });

beforeAll(() => {
  polly = setupPolly('protinfo');
});

afterAll(async () => {
  await polly.stop();
});

beforeEach(() => {
  output = [];
});

test('test with default args', async () => {
  const command = new Protinfo();
  await command.run(["P78330"], { header: true, format: "csv" });
  expect(output[0].startsWith("protein,name,taxon_id,taxon_name,taxon_rank,ec_number,go_term,ipr_code")).toBeTruthy();
  expect(output[1].startsWith("P78330,Phosphoserine phosphatase,9606,Homo sapiens")).toBeTruthy();
  expect(output.length).toBeGreaterThanOrEqual(2);
});

test('test with fasta', async () => {
  const command = new Protinfo();
  await command.run([">test", "P78330"], { header: true, format: "csv" });
  expect(output[0].startsWith("fasta_header,protein,name,taxon_id,taxon_name,taxon_rank,ec_number,go_term,ipr_code")).toBeTruthy();
  expect(output[1].startsWith(">test,P78330,Phosphoserine phosphatase,9606,Homo sapiens")).toBeTruthy();
  expect(output.length).toBeGreaterThanOrEqual(2);
});
