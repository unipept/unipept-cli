import { Unipept } from '../../lib/commands/unipept.js';
import { vi, test, expect, afterEach } from 'vitest';

afterEach(() => {
  vi.restoreAllMocks();
});

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mockFetch = (impl: any) => vi.spyOn(global, 'fetch').mockImplementation(impl);

const metadataResponse = { ok: true, json: async () => ({ db_version: "2026.02" }) } as Response;

test('test if all commands are available', async () => {
  const command = new Unipept();
  const commandNames = command.program.commands.map(c => c.name());
  expect(commandNames).toContain("pept2lca");
});

test('test version reports the UniProt release of the server', async () => {
  const command = new Unipept();
  mockFetch(async () => metadataResponse);

  expect(await command.versionString()).toBe(`${command.version} (UniProt 2026.02)`);
});

test('test version falls back to the cli version when the server is unreachable', async () => {
  const command = new Unipept();
  mockFetch(async () => { throw new Error("Network error"); });

  expect(await command.versionString()).toBe(command.version);
});

test('test version falls back to the cli version when the server errors', async () => {
  const command = new Unipept();
  mockFetch(async () => ({ ok: false, status: 500 } as Response));

  expect(await command.versionString()).toBe(command.version);
});

test('test version flags are handled without parsing arguments', async () => {
  mockFetch(async () => metadataResponse);
  const written: string[] = [];
  vi.spyOn(process.stdout, 'write').mockImplementation((chunk) => { written.push(String(chunk)); return true; });

  const command = new Unipept();
  for (const flag of ["-V", "--version"]) {
    await command.run([flag]);
  }

  const expected = `${command.version} (UniProt 2026.02)\n`;
  expect(written).toStrictEqual([expected, expected]);
});
