import { Pept2lca } from '../../../lib/commands/unipept/pept2lca.js';
import { vi, describe, test, expect, afterEach, beforeEach } from 'vitest';
import { mkdtempSync, rmSync, writeFileSync } from 'fs';
import { tmpdir } from 'os';
import path from 'path';

describe('UnipeptSubcommand', () => {
  const originalIsTTY = process.stdin.isTTY;
  const originalPlatform = process.platform;

  let directory: string;

  /** Writes a file with the given lines and returns its path. */
  const file = (name: string, ...lines: string[]): string => {
    const filePath = path.join(directory, name);
    writeFileSync(filePath, lines.map(line => `${line}\n`).join(""));
    return filePath;
  };

  /** Drains an input iterator into an array. */
  const collect = async (iterator: AsyncIterableIterator<string>): Promise<string[]> => {
    const lines: string[] = [];
    for await (const line of iterator) lines.push(line);
    return lines;
  };

  beforeEach(() => {
    directory = mkdtempSync(path.join(tmpdir(), 'unipept-cli-test-'));
  });

  afterEach(() => {
    vi.restoreAllMocks();
    rmSync(directory, { recursive: true, force: true });
    Object.defineProperty(process.stdin, 'isTTY', { value: originalIsTTY, configurable: true });
    Object.defineProperty(process, 'platform', { value: originalPlatform, configurable: true });
  });

  test('test command setup', () => {
    const command = new Pept2lca();
    expect(command.name).toBe("pept2lca");
    expect(command.user_agent).toMatch(/^unipept-cli/);
    expect(command.command.name()).toBe("pept2lca");
  });

  test('test correct host', () => {
    const command = new Pept2lca();

    expect(command.host).toBe("https://api.unipept.ugent.be");
    expect(command["getHost"]()).toBe("https://api.unipept.ugent.be");

    command.options.host = "https://optionshost";
    expect(command["getHost"]()).toBe("https://optionshost");

    command.options.host = "http://optionshost";
    expect(command["getHost"]()).toBe("http://optionshost");

    command.options.host = "optionshost";
    expect(command["getHost"]()).toBe("http://optionshost");
  });

  test('test correct inputIterator', async () => {
    const command = new Pept2lca();

    // should be stdin
    let input = command["getInputIterator"]([]) as AsyncIterableIterator<string>;
    expect(typeof input[Symbol.asyncIterator]).toBe("function");
    command['streamInterface']?.close();

    // should be a (non-existant) file and error
    input = command["getInputIterator"]([], "filename") as AsyncIterableIterator<string>;
    expect(typeof input[Symbol.asyncIterator]).toBe("function");
    await expect(async () => { await input.next() }).rejects.toThrow(/no such file/);

    // should be array
    const inputArray = command["getInputIterator"](["A", "B"]) as IterableIterator<string>;
    expect(typeof inputArray[Symbol.iterator]).toBe("function");
  });

  test('test selected fields parsing', () => {
    const command = new Pept2lca();

    command.options.select = ["a,b,c"];
    expect(command["getSelectedFields"]()).toStrictEqual([/^a$/, /^b$/, /^c$/]);
  });

  test('test selected fields with wildcards', () => {
    const command = new Pept2lca();

    command.options.select = ["taxon*,name"];
    expect(command["getSelectedFields"]()).toStrictEqual([/^taxon.*$/, /^name$/]);
  });

  test('test inputIterator prints warning when reading from TTY stdin', async () => {
    const command = new Pept2lca();

    // Mock process.stdin.isTTY
    Object.defineProperty(process.stdin, 'isTTY', { value: true, configurable: true });

    // Mock process.stderr.write
    const stderrSpy = vi.spyOn(process.stderr, 'write').mockImplementation(() => true);

    command["getInputIterator"]([]);

    expect(stderrSpy).toHaveBeenCalledWith(expect.stringContaining("Reading from standard input..."));

    command['streamInterface']?.close();
  });

  test('test inputIterator prints correct EOF key for Windows', async () => {
    const command = new Pept2lca();

    Object.defineProperty(process.stdin, 'isTTY', { value: true, configurable: true });
    Object.defineProperty(process, 'platform', { value: 'win32', configurable: true });

    const stderrSpy = vi.spyOn(process.stderr, 'write').mockImplementation(() => true);

    command["getInputIterator"]([]);

    expect(stderrSpy).toHaveBeenCalledWith(expect.stringContaining("Ctrl+Z, Enter"));

    command['streamInterface']?.close();
  });

  test('test inputIterator prints correct EOF key for non-Windows', async () => {
    const command = new Pept2lca();

    Object.defineProperty(process.stdin, 'isTTY', { value: true, configurable: true });
    Object.defineProperty(process, 'platform', { value: 'linux', configurable: true });

    const stderrSpy = vi.spyOn(process.stderr, 'write').mockImplementation(() => true);

    command["getInputIterator"]([]);

    expect(stderrSpy).toHaveBeenCalledWith(expect.stringContaining("Ctrl+D"));

    command['streamInterface']?.close();
  });

  test('test inputIterator prints correct EOF key for macOS', async () => {
    const command = new Pept2lca();

    Object.defineProperty(process.stdin, 'isTTY', { value: true, configurable: true });
    Object.defineProperty(process, 'platform', { value: 'darwin', configurable: true });

    const stderrSpy = vi.spyOn(process.stderr, 'write').mockImplementation(() => true);

    command["getInputIterator"]([]);

    expect(stderrSpy).toHaveBeenCalledWith(expect.stringContaining("Ctrl+D"));

    command['streamInterface']?.close();
  });

  test('test inputIterator reads a single file', async () => {
    const command = new Pept2lca();
    const input = command["getInputIterator"]([], file("a.txt", "AALTER", "MLGIIR")) as AsyncIterableIterator<string>;

    expect(await collect(input)).toStrictEqual(["AALTER", "MLGIIR"]);
  });

  test('test inputIterator reads several files in order', async () => {
    const command = new Pept2lca();
    const files = [file("a.txt", "AALTER"), file("b.txt", "ENFVYIAK", "MLGIIR"), file("c.txt", "QWERTYK")];
    const input = command["getInputIterator"]([], files) as AsyncIterableIterator<string>;

    expect(await collect(input)).toStrictEqual(["AALTER", "ENFVYIAK", "MLGIIR", "QWERTYK"]);
  });

  test('test inputIterator carries fasta headers across a file boundary', async () => {
    const command = new Pept2lca();
    const files = [file("a.txt", ">protein1", "AALTER"), file("b.txt", "ENFVYIAK")];
    const input = command["getInputIterator"]([], files) as AsyncIterableIterator<string>;

    // chaining files behaves exactly like concatenating them, so the header keeps applying
    expect(await collect(input)).toStrictEqual([">protein1", "AALTER", "ENFVYIAK"]);
  });

  test('test inputIterator names the file it cannot read', async () => {
    const command = new Pept2lca();
    const missing = path.join(directory, "missing.txt");
    const input = command["getInputIterator"]([], [file("a.txt", "AALTER"), missing]) as AsyncIterableIterator<string>;

    // every file is checked before the first line is produced, so nothing is emitted
    // from the readable file before the failure is reported
    await expect(input.next()).rejects.toThrow(`Unable to read input file '${missing}': no such file or directory`);
  });

  test('test arguments take priority over input files', async () => {
    const command = new Pept2lca();
    const input = command["getInputIterator"](["MLGIIR"], [file("a.txt", "AALTER")]) as IterableIterator<string>;

    expect([...input]).toStrictEqual(["MLGIIR"]);
  });

  test('test empty input files are handled without contacting the API', async () => {
    const command = new Pept2lca();
    const fetchSpy = vi.spyOn(global, 'fetch');

    await expect(command.run([], { format: "csv", input: [file("a.txt"), file("b.txt")] })).resolves.toBeUndefined();
    expect(fetchSpy).not.toHaveBeenCalled();
  });

  test('test empty input is handled without contacting the API', async () => {
    const command = new Pept2lca();
    const fetchSpy = vi.spyOn(global, 'fetch');
    // @ts-ignore
    vi.spyOn(command, 'getInputIterator').mockReturnValue([].values());

    await expect(command.run([], { format: "csv" })).resolves.toBeUndefined();
    expect(fetchSpy).not.toHaveBeenCalled();
  });

  test('test inputIterator does NOT print warning when reading from piped stdin (not TTY)', async () => {
    const command = new Pept2lca();

    // Mock process.stdin.isTTY
    Object.defineProperty(process.stdin, 'isTTY', { value: false, configurable: true });

    // Mock process.stderr.write
    const stderrSpy = vi.spyOn(process.stderr, 'write').mockImplementation(() => true);

    command["getInputIterator"]([]);

    expect(stderrSpy).not.toHaveBeenCalled();

    command['streamInterface']?.close();
  });

  test('test select does not swallow the arguments that follow it', () => {
    const command = new Pept2lca();
    const seen: { args: string[], options: Record<string, unknown> }[] = [];
    vi.spyOn(command, 'run').mockImplementation(async (args, options) => { seen.push({ args, options }); });

    command.command.parse(["-s", "peptide,taxon_id", "AALTER", "ENFVYIAK"], { from: "user" });

    expect(seen[0].args).toStrictEqual(["AALTER", "ENFVYIAK"]);
    expect(seen[0].options.select).toStrictEqual(["peptide,taxon_id"]);
  });

  test('test select can be repeated', () => {
    const command = new Pept2lca();
    const seen: { args: string[], options: Record<string, unknown> }[] = [];
    vi.spyOn(command, 'run').mockImplementation(async (args, options) => { seen.push({ args, options }); });

    command.command.parse(["-s", "peptide", "-s", "taxon_name", "AALTER"], { from: "user" });

    expect(seen[0].args).toStrictEqual(["AALTER"]);
    expect(seen[0].options.select).toStrictEqual(["peptide", "taxon_name"]);
  });

  test('test selected fields expand from both comma lists and repeats', () => {
    const command = new Pept2lca();

    command.options.select = ["peptide,taxon_id", "taxon_name"];
    expect(command["getSelectedFields"]()).toStrictEqual([/^peptide$/, /^taxon_id$/, /^taxon_name$/]);
  });
});
