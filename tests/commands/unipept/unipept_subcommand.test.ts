import { Pept2lca } from '../../../lib/commands/unipept/pept2lca.js';
import { vi, describe, test, expect, afterEach } from 'vitest';

describe('UnipeptSubcommand', () => {
  const originalIsTTY = process.stdin.isTTY;
  const originalPlatform = process.platform;

  afterEach(() => {
    vi.restoreAllMocks();
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

    const input = command["getInputIterator"]([]) as AsyncIterableIterator<string>;

    expect(stderrSpy).toHaveBeenCalledWith(expect.stringContaining("Reading from standard input..."));

    command['streamInterface']?.close();
  });

  test('test inputIterator prints correct EOF key for Windows', async () => {
    const command = new Pept2lca();

    Object.defineProperty(process.stdin, 'isTTY', { value: true, configurable: true });
    Object.defineProperty(process, 'platform', { value: 'win32', configurable: true });

    const stderrSpy = vi.spyOn(process.stderr, 'write').mockImplementation(() => true);

    const input = command["getInputIterator"]([]) as AsyncIterableIterator<string>;

    expect(stderrSpy).toHaveBeenCalledWith(expect.stringContaining("Ctrl+Z, Enter"));

    command['streamInterface']?.close();
  });

  test('test inputIterator prints correct EOF key for non-Windows', async () => {
    const command = new Pept2lca();

    Object.defineProperty(process.stdin, 'isTTY', { value: true, configurable: true });
    Object.defineProperty(process, 'platform', { value: 'linux', configurable: true });

    const stderrSpy = vi.spyOn(process.stderr, 'write').mockImplementation(() => true);

    const input = command["getInputIterator"]([]) as AsyncIterableIterator<string>;

    expect(stderrSpy).toHaveBeenCalledWith(expect.stringContaining("Ctrl+D"));

    command['streamInterface']?.close();
  });

  test('test inputIterator prints correct EOF key for macOS', async () => {
    const command = new Pept2lca();

    Object.defineProperty(process.stdin, 'isTTY', { value: true, configurable: true });
    Object.defineProperty(process, 'platform', { value: 'darwin', configurable: true });

    const stderrSpy = vi.spyOn(process.stderr, 'write').mockImplementation(() => true);

    const input = command["getInputIterator"]([]) as AsyncIterableIterator<string>;

    expect(stderrSpy).toHaveBeenCalledWith(expect.stringContaining("Ctrl+D"));

    command['streamInterface']?.close();
  });

  test('test inputIterator does NOT print warning when reading from piped stdin (not TTY)', async () => {
    const command = new Pept2lca();

    // Mock process.stdin.isTTY
    Object.defineProperty(process.stdin, 'isTTY', { value: false, configurable: true });

    // Mock process.stderr.write
    const stderrSpy = vi.spyOn(process.stderr, 'write').mockImplementation(() => true);

    const input = command["getInputIterator"]([]) as AsyncIterableIterator<string>;

    expect(stderrSpy).not.toHaveBeenCalled();

    command['streamInterface']?.close();
  });
});
