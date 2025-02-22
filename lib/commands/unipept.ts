import { BaseCommand } from './base_command.js';
import { Pept2ec } from './unipept/pept2ec.js';
import { Pept2funct } from './unipept/pept2funct.js';
import { Pept2go } from './unipept/pept2go.js';
import { Pept2interpro } from './unipept/pept2interpro.js';
import { Pept2lca } from './unipept/pept2lca.js';
import { Pept2prot } from './unipept/pept2prot.js';
import { Pept2taxa } from './unipept/pept2taxa.js';
import { Peptinfo } from './unipept/peptinfo.js';
import { Protinfo } from './unipept/protinfo.js';
import { Taxa2lca } from './unipept/taxa2lca.js';
import { Taxonomy } from './unipept/taxonomy.js';

export class Unipept extends BaseCommand {

  readonly description = `The unipept subcommands are command line wrappers around the Unipept web services.

Subcommands that start with pept expect a list of tryptic peptides as input. Subcommands that start with tax expect a list of NCBI Taxonomy Identifiers as input. Input is passed

- as separate command line arguments
- in a text file that is passed as an argument to the -i option
- to standard input

The command will give priority to the first way the input is passed, in the order as listed above. Text files and standard input should have one tryptic peptide or one NCBI Taxonomy Identifier per line.`;

  constructor(options?: { exitOverride?: boolean, suppressOutput?: boolean }) {
    super(options);

    this.program
      .summary("Command line interface to Unipept web services.")
      .description(this.description)
      .addCommand(new Pept2ec().command)
      .addCommand(new Pept2funct().command)
      .addCommand(new Pept2go().command)
      .addCommand(new Pept2interpro().command)
      .addCommand(new Pept2lca().command)
      .addCommand(new Pept2prot().command)
      .addCommand(new Pept2taxa().command)
      .addCommand(new Peptinfo().command)
      .addCommand(new Protinfo().command)
      .addCommand(new Taxa2lca().command)
      .addCommand(new Taxonomy().command);
  }

  async run(args?: string[]) {
    this.parseArguments(args);
  }
}
