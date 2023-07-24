require 'typhoeus'

require_relative '../batch_order'
require_relative '../batch_iterator'
require_relative '../configuration'
require_relative '../formatters'
require_relative '../output_writer'
require_relative '../server_message'
require_relative '../version'

require_relative 'unipept/config'
require_relative 'unipept/pept2ec'
require_relative 'unipept/pept2funct'
require_relative 'unipept/pept2go'
require_relative 'unipept/pept2interpro'
require_relative 'unipept/pept2lca'
require_relative 'unipept/pept2prot'
require_relative 'unipept/pept2taxa'
require_relative 'unipept/peptinfo'
require_relative 'unipept/protinfo'
require_relative 'unipept/taxa2lca'
require_relative 'unipept/taxonomy'
require_relative 'unipept/taxa2tree'

module Unipept
  class Commands::Unipept
    def initialize
      @root_command = create_root_command
      add_config_command
      add_pept2taxa_command
      add_pept2ec_command
      add_pept2funct_command
      add_pept2go_command
      add_pept2interpro_command
      add_pept2lca_command
      add_peptinfo_command
      add_protinfo_command
      add_taxa2lca_command
      add_pept2prot_command
      add_taxonomy_command
      add_taxa2tree_command
    end

    def run(args)
      @root_command.run(args)
    end

    def create_root_command
      Cri::Command.new_basic_root.modify do
        name 'unipept'
        summary 'Command line interface to Unipept web services.'
        usage 'unipept subcommand [options]'
        description <<-EOS
        The unipept subcommands are command line wrappers around the Unipept web services.

        Subcommands that start with pept expect a list of tryptic peptides as input. Subcommands that start with tax expect a list of NCBI Taxonomy Identifiers as input. Input is passed

        - as separate command line arguments

        - in a text file that is passed as an argument to the -i option

        - to standard input

        The command will give priority to the first way the input is passed, in the order as listed above. Text files and standard input should have one tryptic peptide or one NCBI Taxonomy Identifier per line.
        EOS
        flag :v, :version, 'displays the version'
        flag :q, :quiet, 'disable service messages'
        flag nil, :'no-header', 'disable header in csv output', hidden: true
        option :i, :input, 'read input from file', argument: :required
        option nil, :batch, 'specify the batch size', argument: :required, hidden: true
        option nil, :parallel, 'specify the number of parallel requests', argument: :required, hidden: true
        option :o, :output, 'write output to file', argument: :required
        option :f, :format, "define the output format (available: #{Unipept::Formatter.available.select { |f| f != 'html' && f != 'url' }.join(', ')}) (default: #{Unipept::Formatter.default}).", argument: :required

        # Configuration options
        option nil, 'host', 'specify the server running the Unipept web service', argument: :required

        run do |opts, _args, cmd|
          if opts[:version]
            puts Unipept::VERSION
          else
            abort cmd.help
          end
        end
      end
    end

    def add_config_command
      @root_command.define_command('config') do
        summary 'Set configuration options.'
        usage 'config option [value]'
        description <<-EOS
        Sets or shows the value for configuration options. All settings are stored in the .unipeptrc file in the home directory of the user.

        Running the command with a value will set that value for the given option, running it without will show the current value.

        These options are currently supported:

        - host: Set the default host for api calls.

        Example: "unipept config host http://api.unipept.ugent.be" will set the default host to the public unipept server.
        EOS

        runner Commands::Config
      end
    end

    def add_pept2taxa_command
      @root_command.define_command('pept2taxa') do
        usage 'pept2taxa [options]'
        summary 'Fetch taxa of UniProt entries that match tryptic peptides.'
        description <<-EOS
        For each tryptic peptide the unipept pept2taxa command retrieves from Unipept the set of taxa from all UniProt entries whose protein sequence contains an exact matches to the tryptic peptide. The command expects a list of tryptic peptides that are passed

        - as separate command line arguments

        - in a text file that is passed as an argument to the -i option

        - to standard input

        The command will give priority to the first way tryptic peptides are passed, in the order as listed above. Text files and standard input should have one tryptic peptide per line.
        EOS

        flag :e, :equate, 'equate isoleucine (I) and leucine (L) when matching peptides'
        flag :a, :all, 'report all information fields of NCBI Taxonomy records available in Unipept. Note that this may have a performance penalty.'
        option :s, :select, 'select the information fields to return. Selected fields are passed as a comma separated list of field names. Multiple -s (or --select) options may be used.', argument: :required, multiple: true

        runner Commands::Pept2taxa
      end
    end

    def add_pept2ec_command
      @root_command.define_command('pept2ec') do
        usage 'pept2ec[options]'
        summary 'Fetch EC numbers of UniProt entries that match tryptic peptides.'
        description <<-EOS
        For each tryptic peptide the unipept pept2ec command retrieves from Unipept the set of EC numbers from all UniProt entries whose protein sequence contains an exact matches to the tryptic peptide. The command expects a list of tryptic peptides that are passed

        - as separate command line arguments

        - in a text file that is passed as an argument to the -i option

        - to standard input

        The command will give priority to the first way tryptic peptides are passed, in the order as listed above. Text files and standard input should have one tryptic peptide per line.
        EOS

        flag :e, :equate, 'equate isoleucine (I) and leucine (L) when matching peptides'
        flag :a, :all, 'Also return the names of the EC numbers. Note that this may have a performance penalty.'
        option :s, :select, 'select the information fields to return. Selected fields are passed as a comma separated list of field names. Multiple -s (or --select) options may be used.', argument: :required, multiple: true

        runner Commands::Pept2ec
      end
    end

    def add_pept2funct_command
      @root_command.define_command('pept2funct') do
        usage 'pept2funct[options]'
        summary 'Fetch EC numbers, GO terms and InterPro codes of UniProt entries that match tryptic peptides.'
        description <<-EOS
        For each tryptic peptide the unipept pept2funct command retrieves from Unipept the set of EC numbers and GO terms from all UniProt entries whose protein sequence contains an exact matches to the tryptic peptide. The command expects a list of tryptic peptides that are passed

        - as separate command line arguments

        - in a text file that is passed as an argument to the -i option

        - to standard input

        The command will give priority to the first way tryptic peptides are passed, in the order as listed above. Text files and standard input should have one tryptic peptide per line.
        EOS

        flag :e, :equate, 'equate isoleucine (I) and leucine (L) when matching peptides'
        flag :a, :all, 'Also return the names of the EC numbers, GO terms and InterPro codes. Note that this may have a performance penalty.'
        option :s, :select, 'select the information fields to return. Selected fields are passed as a comma separated list of field names. Multiple -s (or --select) options may be used.', argument: :required, multiple: true

        runner Commands::Pept2funct
      end
    end

    def add_pept2go_command
      @root_command.define_command('pept2go') do
        usage 'pept2go [options]'
        summary 'Fetch GO terms of UniProt entries that match tryptic peptides.'
        description <<-EOS
        For each tryptic peptide the unipept pept2go command retrieves from Unipept the set of GO terms from all UniProt entries whose protein sequence contains an exact matches to the tryptic peptide. The command expects a list of tryptic peptides that are passed

        - as separate command line arguments

        - in a text file that is passed as an argument to the -i option

        - to standard input

        The command will give priority to the first way tryptic peptides are passed, in the order as listed above. Text files and standard input should have one tryptic peptide per line.
        EOS

        flag :e, :equate, 'equate isoleucine (I) and leucine (L) when matching peptides'
        flag :a, :all, 'Also return the names of the GO terms. Note that this may have a performance penalty.'
        option :s, :select, 'select the information fields to return. Selected fields are passed as a comma separated list of field names. Multiple -s (or --select) options may be used.', argument: :required, multiple: true

        runner Commands::Pept2go
      end
    end

    def add_pept2interpro_command
      @root_command.define_command('pept2interpro') do
        usage 'pept2interpro [options]'
        summary 'Fetch InterPro entries of UniProt entries that match tryptic peptides.'
        description <<-EOS
        For each tryptic peptide the unipept pept2interpro command retrieves from Unipept the set of InterPro entries from all UniProt entries whose protein sequence contains an exact matches to the tryptic peptide. The command expects a list of tryptic peptides that are passed

        - as separate command line arguments

        - in a text file that is passed as an argument to the -i option

        - to standard input

        The command will give priority to the first way tryptic peptides are passed, in the order as listed above. Text files and standard input should have one tryptic peptide per line.
        EOS

        flag :e, :equate, 'equate isoleucine (I) and leucine (L) when matching peptides'
        flag :a, :all, 'Also return the names and types of the InterPro entries. Note that this may have a performance penalty.'
        option :s, :select, 'select the information fields to return. Selected fields are passed as a comma separated list of field names. Multiple -s (or --select) options may be used.', argument: :required, multiple: true

        runner Commands::Pept2interpro
      end
    end

    def add_pept2lca_command
      @root_command.define_command('pept2lca') do
        usage 'pept2lca [options]'
        summary 'Fetch taxonomic lowest common ancestor of UniProt entries that match tryptic peptides.'
        description <<-EOS
        For each tryptic peptide the unipept pept2lca command retrieves from Unipept the lowest common ancestor of the set of taxa from all UniProt entries whose protein sequence contains an exact matches to the tryptic peptide. The lowest common ancestor is based on the topology of the Unipept Taxonomy -- a cleaned up version of the NCBI Taxonomy -- and is itself a record from the NCBI Taxonomy. The command expects a list of tryptic peptides that are passed

         - as separate command line arguments

         - in a text file that is passed as an argument to the -i option

         - to standard input

        The command will give priority to the first way tryptic peptides are passed, in the order as listed above. Text files and standard input should have one tryptic peptide per line.
        EOS

        flag :e, :equate, 'equate isoleucine (I) and leucine (L) when matching peptides'
        flag :a, :all, 'report all information fields of NCBI Taxonomy records available in Unipept. Note that this may have a performance penalty.'
        option :s, :select, 'select the information fields to return. Selected fields are passed as a comma separated list of field names. Multiple -s (or --select) options may be used.', argument: :required, multiple: true

        runner Commands::Pept2lca
      end
    end

    def add_peptinfo_command
      @root_command.define_command('peptinfo') do
        usage 'peptinfo [options]'
        summary 'Fetch functional information and the taxonomic lowest common ancestor of UniProt entries that match tryptic peptides.'
        description <<-EOS
        For each tryptic peptide the unipept peptinfo command retrieves from Unipept the functional information and the lowest common ancestor of the set of taxa from all UniProt entries whose protein sequence contains an exact matches to the tryptic peptide. The lowest common ancestor is based on the topology of the Unipept Taxonomy -- a cleaned up version of the NCBI Taxonomy -- and is itself a record from the NCBI Taxonomy. The command expects a list of tryptic peptides that are passed

         - as separate command line arguments

         - in a text file that is passed as an argument to the -i option

         - to standard input

        The command will give priority to the first way tryptic peptides are passed, in the order as listed above. Text files and standard input should have one tryptic peptide per line.
        EOS

        flag :e, :equate, 'equate isoleucine (I) and leucine (L) when matching peptides'
        flag :a, :all, 'report the names of the functional annotations and all information fields of NCBI Taxonomy records available in Unipept. Note that this may have a performance penalty.'
        option :s, :select, 'select the information fields to return. Selected fields are passed as a comma separated list of field names. Multiple -s (or --select) options may be used.', argument: :required, multiple: true

        runner Commands::Peptinfo
      end
    end

    def add_protinfo_command
      @root_command.define_command('protinfo') do
        usage 'protinfo [options]'
        summary 'Fetch functional and taxonomic information of UniProt ids'
        description <<-EOS
        For each UniProt id the unipept protinfo command retrieves from Unipept the functional information and the NCBI id. The command expects a list of UniProt ids that are passed

         - as separate command line arguments

         - in a text file that is passed as an argument to the -i option

         - to standard input

        The command will give priority to the first way tryptic peptides are passed, in the order as listed above. Text files and standard input should have one tryptic peptide per line.
        EOS

        option :s, :select, 'select the information fields to return. Selected fields are passed as a comma separated list of field names. Multiple -s (or --select) options may be used.', argument: :required, multiple: true

        runner Commands::Protinfo
      end
    end

    def add_taxa2lca_command
      @root_command.define_command('taxa2lca') do
        usage 'taxa2lca [options]'
        summary 'Compute taxonomic lowest common ancestor for given list of taxa.'
        description <<-EOS
        The unipept taxa2lca command computes the lowest common ancestor of a given list of NCBI Taxonomy Identifiers. The lowest common ancestor is based on the topology of the Unipept Taxonomy -- a cleaned up version of the NCBI Taxonomy -- and is itself a record from the NCBI Taxonomy. The command expects a list of NCBI Taxonomy Identifiers that are passed

         - as separate command line arguments

         - in a text file that is passed as an argument to the -i option

         - to standard input

        The command will give priority to the first way NCBI Taxonomy Identifiers are passed, in the order as listed above. Text files and standard input should have one NCBI Taxonomy Identifier per line.
        EOS

        flag :a, :all, 'report all information fields of NCBI Taxonomy records available in Unipept. Note that this may have a performance penalty.'
        option :s, :select, 'select the information fields to return. Selected fields are passed as a comma separated list of field names. Multiple -s (or --select) options may be used.', argument: :required, multiple: true

        runner Commands::Taxa2lca
      end
    end

    def add_taxa2tree_command
      @root_command.define_command('taxa2tree') do
        usage 'taxa2tree [options]'
        summary 'Compute lineage tree for given list of taxa'
        description <<-EOS
        The unipept taxa2tree command computes a lineage tree of a given list of NCBI Taxonomy Identifiers. A frequency table is computed for the given list of taxa. Secondly, the lineages for all taxa are looked up. These are then used to build a lineage tree with all counts set. The command expects a list of NCBI Taxonomy Identifiers that are passed

         - as separate command line arguments

         - in a text file that is passed as an argument to the -i option

         - to standard input

        The command will give priority to the first way NCBI Taxonomy Identifiers are passed, in the order as listed above. Text files and standard input should have one NCBI Taxonomy Identifier per line.
        EOS

        option :f, :format, "define the output format (available: json, url, html) (default: 'json'). Note that xml and csv are not available for taxa2tree. html and url are used as an output format for visualizations.", argument: :required

        runner Commands::Taxa2Tree
      end
    end

    def add_pept2prot_command
      @root_command.define_command('pept2prot') do
        usage 'pept2prot [options]'
        summary 'Fetch UniProt entries that match tryptic peptides.'
        description <<-EOS
        For each tryptic peptide the unipept pept2prot command retrieves from Unipept all UniProt entries whose protein sequence contains an exact matches to the tryptic peptide. The command expects a list of tryptic peptides that are passed

        - as separate command line arguments

        - in a text file that is passed as an argument to the -i option

        - to standard input

        The command will give priority to the first way tryptic peptides are passed, in the order as listed above. Text files and standard input should have one tryptic peptide per line.
        EOS

        flag :e, :equate, 'equate isoleucine (I) and leucine (L) when matching peptides'
        flag :a, :all, 'report all information fields of UniProt entries available in Unipept. Note that this may have a performance penalty.'
        option :s, :select, 'select the information fields to return. Selected fields are passed as a comma separated list of field names. Multiple -s (or --select) options may be used.', argument: :required, multiple: true
        option nil, :meganize, 'output the results in a BlastTab-like format that MEGAN can understand'

        runner Commands::Pept2prot
      end
    end

    def add_taxonomy_command
      @root_command.define_command('taxonomy') do
        usage 'taxonomy [options]'
        summary 'Fetch taxonomic information from Unipept Taxonomy.'
        description <<-EOS
        The unipept taxonomy command yields information from the Unipept Taxonomy records for a given list of NCBI Taxonomy Identifiers. The Unipept Taxonomy is a cleaned up version of the NCBI Taxonomy, and its records are also records of the NCBI Taxonomy. The command expects a list of NCBI Taxonomy Identifiers that are passed

        - as separate command line arguments

        - in a text file that is passed as an argument to the -i option

        - to standard input

        The command will give priority to the first way NCBI Taxonomy Identifiers are passed, in the order as listed above. Text files and standard input should have one NCBI Taxonomy Identifier per line.
        EOS

        flag :a, :all, 'report all information fields of NCBI Taxonomy records available in Unipept. Note that this may have a performance penalty.'
        option :s, :select, 'select the information fields to return. Selected fields are passed as a comma separated list of field names. Multiple -s (or --select) options may be used.', argument: :required, multiple: true

        runner Commands::Taxonomy
      end
    end

    # Invokes the unipept command-line tool with the given arguments.
    #
    # @param [Array<String>] args An array of command-line arguments
    #
    # @return [void]
    def self.run(args)
      new.run(args)
    end
  end
end
