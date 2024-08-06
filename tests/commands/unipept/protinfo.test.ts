import { jest } from '@jest/globals';
import { Protinfo } from "../../../lib/commands/unipept/protinfo";

let output: string[];
jest
  .spyOn(process.stdout, "write")
  .mockImplementation((data: unknown) => { output.push(data as string); return true; });

beforeEach(() => {
  output = [];
});

test('test with default args', async () => {
  const command = new Protinfo();
  await command.run(["P78330"], { header: true, format: "csv" });
  expect(output[0].startsWith("protein,taxon_id,taxon_name,taxon_rank,ec_number,go_term,ipr_code")).toBeTruthy();
  expect(output[1].startsWith("P78330,9606,Homo sapiens")).toBeTruthy();
  expect(output.length).toBe(2);
});

test('test with fasta', async () => {
  const command = new Protinfo();
  await command.run([">test", "P78330"], { header: true, format: "csv" });
  expect(output[0].startsWith("fasta_header,protein,taxon_id,taxon_name,taxon_rank,ec_number,go_term,ipr_code")).toBeTruthy();
  expect(output[1].startsWith(">test,P78330,9606,Homo sapiens")).toBeTruthy();
  expect(output.length).toBe(2);
});
