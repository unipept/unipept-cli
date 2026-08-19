import { expect, test } from 'vitest';
import { existsSync, readFileSync } from 'node:fs';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '../..');
const pkg = JSON.parse(readFileSync(path.join(root, 'package.json'), 'utf8'));

test('test every declared bin points at a source file that exists', () => {
  for (const [name, target] of Object.entries(pkg.bin as Record<string, string>)) {
    // the bins point into dist/, which only exists after a build, so check the source they compile from
    const source = path.join(root, String(target).replace(/^\.\/dist\//, '').replace(/\.js$/, '.ts'));
    expect(existsSync(source), `${name} -> ${target} has no source at ${source}`).toBe(true);
  }
});

test('test npx can resolve a bin named after the package', () => {
  // npx runs the bin matching the package name, and only falls back to the sole bin when
  // there is exactly one. This package ships several, so the alias is what makes npx work.
  expect(Object.keys(pkg.bin)).toContain(pkg.name);
  expect(pkg.bin[pkg.name]).toBe(pkg.bin.unipept);
});
