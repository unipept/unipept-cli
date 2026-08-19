import { existsSync, readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

/**
 * Locates package.json by walking up from this module and reads its version.
 *
 * The compiled output lives one directory deeper than the sources (dist/lib/... vs lib/...),
 * so a hardcoded relative path has to differ between the two layouts, and differ again per
 * source file depth. Searching upwards instead keeps this correct wherever the file ends up.
 */
function readVersion(): string {
  let directory = dirname(fileURLToPath(import.meta.url));

  for (;;) {
    const candidate = join(directory, "package.json");
    if (existsSync(candidate)) {
      return JSON.parse(readFileSync(candidate, "utf8")).version;
    }

    const parent = dirname(directory);
    if (parent === directory) {
      throw new Error("Unable to locate package.json to read the version from");
    }
    directory = parent;
  }
}

/** The version of this package, as declared in package.json. */
export const version: string = readVersion();
