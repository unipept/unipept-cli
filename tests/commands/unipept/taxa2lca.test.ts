import { jest } from '@jest/globals';
import { Taxa2lca } from "../../../lib/commands/unipept/taxa2lca";

let output: string[];
jest
  .spyOn(process.stdout, "write")
  .mockImplementation((data: unknown) => { output.push(data as string); return true; });

beforeEach(() => {
  output = [];
});

test('test with default args', async () => {
  const command = new Taxa2lca();
  await command.run(["216816", "1680"], { header: true, format: "csv" });
  expect(output[0].startsWith("taxon_id,taxon_name,taxon_rank")).toBeTruthy();
  expect(output[1].startsWith("1678,Bifidobacterium,genus")).toBeTruthy();
  expect(output.length).toBe(2);
});
