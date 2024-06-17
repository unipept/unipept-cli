#!/usr/bin/env node

import { Option, program } from 'commander';
import { createInterface } from 'node:readline';

const VALID_FORMATS = ["fasta", "gff", "json", "rdf", "sequence", "xml"];

program
  .version("1.0.0")
  .summary("Command line interface to UniProt web services.")
  .description(`Command line interface to UniProt web services.

The uniprot command fetches UniProt entries from the UniProt web services. The command expects a list of UniProt Accession Numbers that are passed

- as separate command line arguments
- to standard input

The command will give priority to the first way UniProt Accession Numbers are passed, in the order as listed above. The standard input should have one UniProt Accession Number per line.

The uniprot command yields just the protein sequences as a default, but can return several formats.`)
  .argument("[accessions...]", "UniProt Accession Numbers")
  .addOption(new Option("-f, --format <format>", `output format`).choices(VALID_FORMATS).default("sequence"));

program.parse(process.argv);
const format = program.opts().format;
const accessions = program.args;

if (accessions.length !== 0) {
  accessions.forEach(processUniprotEntry);
} else {
  for await (const line of createInterface({ input: process.stdin })) {
    processUniprotEntry(line.trim());
  };
}

async function processUniprotEntry(accession) {
  process.stdout.write(await getUniprotEntry(accession, format) + "\n");
}

async function getUniprotEntry(accession, format) {
  if (format === "sequence") {
    return (await getUniprotEntry(accession, "fasta"))
      .split("\n")
      .slice(1)
      .join("");
  } else {
    const r = await fetch(`https://rest.uniprot.org/uniprotkb/${accession}.${format}`);
    if (r.ok) {
      return r.text();
    } else {
      process.stderr.write(`Error fetching ${accession}: ${r.status} ${r.statusText}\n`);
      return "";
    }
  }
}
