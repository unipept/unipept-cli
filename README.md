# unipept-cli

[![NPM Version](https://img.shields.io/npm/v/unipept-cli)](https://www.npmjs.com/package/unipept-cli)
[![CI](https://github.com/unipept/unipept-cli/actions/workflows/ci.yml/badge.svg)](https://github.com/unipept/unipept-cli/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/npm/l/unipept-cli)](LICENSE.txt)

Unipept-cli offers a command line interface to the [Unipept](https://unipept.ugent.be) web services for metaproteomics
data analysis. It ships four commands: `unipept`, `prot2pept`, `peptfilter` and `uniprot`.

Every command reads from standard input and writes to standard output, so they compose with each other and with the
usual shell tools.

- Web service documentation: <https://unipept.ugent.be/apidocs>
- Command line documentation: <https://unipept.ugent.be/clidocs>

## Installation

The Unipept CLI needs Node 22 or higher. Check your version with `node -v`:

```console
$ node -v
v22.3.0
```

See the [Node download page](https://nodejs.org/en/download/package-manager) if you need to install or upgrade it.

The CLI is published as an npm package:

```console
$ npm install -g unipept-cli
```

After a successful installation, the commands are available on your `PATH`:

```console
$ unipept --version
4.2.0 (UniProt 2026.02)
```

`unipept --version` also reports the UniProt release that the server built its database from, so
that results can be traced back to a specific release. It falls back to just the cli version when
the server cannot be reached, and the other three commands report the cli version on its own.

Run any command with `-h` to see its full help, for example `unipept -h` or `unipept pept2lca -h`.

## Commands

Every command reads from standard input and writes to standard output by default. All four also
accept `-i/--input` to read from files instead, which may be given more than once to read several
files as a single stream, and `-o/--output` to write to a file:

```console
$ peptfilter -i first.txt -i second.txt -o filtered.txt
```

### `unipept`

Wraps the Unipept web services. Subcommands starting with `pept` take tryptic peptides, subcommands starting with
`tax` take NCBI Taxonomy identifiers.

| Subcommand      | Returns                                                                            |
| --------------- | ---------------------------------------------------------------------------------- |
| `pept2ec`       | EC numbers of the UniProt entries matching each peptide                             |
| `pept2funct`    | EC numbers, GO terms and InterPro entries in one call                               |
| `pept2go`       | GO terms of the UniProt entries matching each peptide                               |
| `pept2interpro` | InterPro entries of the UniProt entries matching each peptide                       |
| `pept2lca`      | Taxonomic lowest common ancestor of the UniProt entries matching each peptide       |
| `pept2prot`     | UniProt entries matching each peptide                                               |
| `pept2taxa`     | Taxa of the UniProt entries matching each peptide                                   |
| `peptinfo`      | Functional information and the taxonomic lowest common ancestor for each peptide    |
| `protinfo`      | Functional and taxonomic information for UniProt ids                                |
| `taxa2lca`      | Taxonomic lowest common ancestor of a list of taxon ids                             |
| `taxonomy`      | Taxonomic information from the Unipept taxonomy                                     |

Input can be passed as command line arguments, in files given with `-i`, or on standard input. The first of these
that is present wins.

```console
$ unipept pept2lca AALTER ENFVYIAK
peptide,cutoff_used,taxon_id,taxon_name,taxon_rank
AALTER,1,1,root,no rank
ENFVYIAK,,1,root,no rank

$ cat peptides.txt | unipept pept2lca
$ unipept pept2lca -i peptides.txt -o results.csv
```

`-i` may be repeated to read several files, which are processed one after the other as if they had
been concatenated, so FASTA headers keep applying across a file boundary. The files are read one at
a time rather than loaded up front, and all of them are checked for readability before any output is
produced, so an unreadable file is reported before a partial result is written.

```console
$ unipept pept2lca -i first.txt -i second.txt -o results.csv
```

Use `--log <file>` to send the messages that normally go to standard error, such as retry notices
and failed requests, to a file instead, and `-q/--quiet` to silence them. Failed requests are
recorded in `~/.unipept/` either way.

Output is CSV by default; `-f json`, `-f xml` and `-f blast` are also available. Use `-s` (repeatable, and
comma-separated lists are accepted) to select a subset of the fields, with `*` as a wildcard:

```console
$ unipept pept2go -s peptide -s go_term ENFVYIAK
```

If the input is FASTA, headers are preserved and added to the output as a `fasta_header` column, so results stay
bundled per protein.

### `prot2pept`

Splits protein sequences into peptides using a cleavage pattern. The default pattern produces tryptic peptides.

```console
$ echo "AALTERSVKAAPKR" | prot2pept
AALTER
SVK
AAPK
R
```

Use `-p` to supply your own cleavage regex. Plain sequences (one per line) and FASTA input are both accepted; FASTA
headers are preserved.

### `peptfilter`

Filters a list of peptides on length and amino acid content. FASTA headers pass through untouched.

```console
$ printf "AALTER\nAA\nAALTERSVKAAPKRQWERTY\n" | peptfilter --minlen 5 --maxlen 10
AALTER
```

```console
$ printf "AALTER\nAALTER\nMLGIIR\n" | peptfilter --unique
AALTER
MLGIIR
```

Options: `--minlen` (default 5), `--maxlen` (default 50), `-c/--contains`, `-l/--lacks` and
`-u/--unique`. Deduplication with `-u` is global rather than per FASTA block, and it has to
remember every distinct peptide it has seen, so it is the one option that makes memory grow with
the input. Without it the command runs in constant memory.

### `uniprot`

Fetches UniProt entries by accession number from the UniProt web services. It returns bare protein sequences by
default, and supports the `fasta`, `gff`, `json`, `rdf`, `sequence` and `xml` formats through `-f`.

```console
$ uniprot P78330
MVSHSELRKLFYSADAVCFDVDSTVIREEGIDELAKICGVEDAVSEMTRRAMGGAVPFKAALTERLALIQPSREQVQRLIAEQPPHLTPGIRELVSRLQER...

$ uniprot -f fasta P78330 Q9UBQ7
```

### Composing commands

Because everything is a stream, the commands chain naturally:

```console
$ cat proteins.fasta | prot2pept | peptfilter --minlen 5 | unipept pept2lca -o lca.csv
```

## Development

```bash
git clone https://github.com/unipept/unipept-cli.git
cd unipept-cli
yarn install
```

| Command          | What it does                                                        |
| ---------------- | ------------------------------------------------------------------- |
| `yarn test`      | Run the test suite against recorded HTTP responses                   |
| `yarn lint`      | Run ESLint                                                           |
| `yarn typecheck` | Type check without emitting                                          |
| `yarn build`     | Compile TypeScript to `dist/`                                        |

To run a command from source without building, use the matching script: `yarn unipept pept2lca AALTER`,
`yarn prot2pept`, `yarn peptfilter` or `yarn uniprot`.

API responses used by the tests are recorded with [Polly.js](https://netflix.github.io/pollyjs/) and stored in
`tests/recordings`. Refresh them against the live API with `yarn test:record`.

Releases are published to npm by the `publish` workflow when a `v*` tag is pushed. The tag must match the version in
`package.json`.

## Citing

If you use the Unipept CLI in your research, please cite:

> Verschaffelt, P., Van Thienen, P., Van Den Bossche, T., Van der Jeugt, F., De Tender, C., Martens, L., Dawyndt, P.,
> & Mesuere, B. (2020). Unipept CLI 2.0: adding support for visualizations and functional annotations.
> *Bioinformatics*, 36(14), 4220–4221. <https://doi.org/10.1093/bioinformatics/btaa553>

See [CITATION.cff](CITATION.cff) for a machine readable version.

## License

MIT, see [LICENSE.txt](LICENSE.txt).
