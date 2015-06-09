require 'typhoeus'

require_relative '../formatters'
require_relative '../configuration'
require_relative '../batch_order'
require_relative '../version'

require_relative 'unipept/pept2lca'
require_relative 'unipept/pept2prot'
require_relative 'unipept/pept2taxa'
require_relative 'unipept/taxa2lca'
require_relative 'unipept/taxonomy'

module Unipept
  class Commands::Unipept
    def initialize
      @root_command = create_root_command
      add_config_command
      add_pept2taxa_command
      add_pept2lca_command
      add_taxa2lca_command
      add_pept2prot_command
      add_taxonomy_command
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

        - in one or more text files that are passed as an argument to the -i option

        - to standard input

        The command will give priority to the first way the input is passed, in the order as listed above. Text files and standard input should have one tryptic peptide or one NCBI Taxonomy Identifier per line.
        EOS
        flag :v, :version, 'displays the version'
        flag :q, :quiet, 'disable service messages'
        option :i, :input, 'read input from file', argument: :required
        option :o, :output, 'write output to file', argument: :required
        option :f, :format, "define the output format (available: #{Unipept::Formatter.available.join ', ' }) (default: #{Unipept::Formatter.default})", argument: :required

        # Configuration options
        option nil, 'host', 'specify the server running the Unipept web service', argument: :required

        run do |opts, _args, _cmd|
          if opts[:version]
            puts File.read(File.join(File.dirname(__FILE__), '..', 'VERSION'))
          else
            root_cmd.run(['help'])
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

        run do |_opts, args, _cmd|
          config = Unipept::Configuration.new
          if args.size > 1
            config[args.first] = args[1]
            config.save
          elsif args.size == 1
            puts config[args.first]
          elsif args.size == 0
            root_cmd.run(['config', '-h'])
          end
        end
      end
    end

    def add_pept2taxa_command
      @root_command.define_command('pept2taxa') do
        usage 'pept2taxa [options]'
        aliases :pt
        summary 'Fetch taxa of Uniprot records that match tryptic peptides.'
        description <<-EOS
        For each tryptic peptide the unipept pept2taxa command retrieves from Unipept the set of taxa from all Uniprot records whose protein sequence contains an exact matches to the tryptic peptide. The command expects a list of tryptic peptides that are passed

        - as separate command line arguments

        - in one or more text files that are passed as an argument to the -i option

        - to standard input

        The command will give priority to the first way tryptic peptides are passed, in the order as listed above. Text files and standard input should have one tryptic peptide per line.

        The unipept pept2taxa subcommand yields NCBI Taxonomy records as output.
        EOS

        flag :e, :equate, 'equate isoleucine (I) and leucine (L) when matching peptides'
        flag :a, :all, 'report all information fields of NCBI Taxonomy records available in Unipept. Note that this may have a performance penalty.'
        option :s, :select, 'select the information fields to return. Selected fields are passed as a comma separated list of field names. Multiple -s (or --select) options may be used.', argument: :required, multiple: true
        option :x, :xml, 'Download the matched records from the NCBI web service as an xml-formatted file (specify output filename)', argument: :required

        runner Commands::Pept2taxa
      end
    end

    def add_pept2lca_command
      @root_command.define_command('pept2lca') do
        usage 'pept2lca [options]'
        aliases :pl
        summary 'Fetch taxonomic lowest common ancestor of Uniprot records that match tryptic peptides.'
        description <<-EOS
        For each tryptic peptide the unipept pept2lca command retrieves from Unipept the lowest common ancestor of the set of taxa from all Uniprot records whose protein sequence contains an exact matches to the tryptic peptide. The lowest common ancestor is based on the topology of the Unipept Taxonomy -- a cleaned up version of the NCBI Taxonomy -- and is itself a record from the NCBI Taxonomy. The command expects a list of tryptic peptides that are passed

         - as separate command line arguments

         - in one or more text files that are passed as an argument to the -i option

         - to standard input

        The command will give priority to the first way tryptic peptides are passed, in the order as listed above. Text files and standard input should have one tryptic peptide per line.

        The unipept pept2lca subcommand yields an NCBI Taxonomy record as output.
        EOS

        flag :e, :equate, 'equate isoleucine (I) and leucine (L) when matching peptides'
        flag :a, :all, 'report all information fields of NCBI Taxonomy records available in Unipept. Note that this may have a performance penalty.'
        option :s, :select, 'select the information fields to return. Selected fields are passed as a comma separated list of field names. Multiple -s (or --select) options may be used.', argument: :required, multiple: true

        runner Commands::Pept2lca
      end
    end

    def add_taxa2lca_command
      @root_command.define_command('taxa2lca') do
        usage 'taxa2lca [options]'
        aliases :tl
        summary 'Compute taxonomic lowest common ancestor for given list of taxa.'
        description <<-EOS
        The unipept taxa2lca command computes the lowest common ancestor of a given list of NCBI Taxonomy Identifiers. The lowest common ancestor is based on the topology of the Unipept Taxonomy -- a cleaned up version of the NCBI Taxonomy -- and is itself a record from the NCBI Taxonomy. The command expects a list of NCBI Taxonomy Identifiers that are passed

         - as separate command line arguments

         - in one or more text files that are passed as an argument to the -i option

         - to standard input

        The command will give priority to the first way NCBI Taxonomy Identifiers are passed, in the order as listed above. Text files and standard input should have one NCBI Taxonomy Identifier per line.

        The unipept taxonomy subcommand yields NCBI Taxonomy records as output.
        EOS

        flag :a, :all, 'report all information fields of NCBI Taxonomy records available in Unipept. Note that this may have a performance penalty.'
        option :s, :select, 'select the information fields to return. Selected fields are passed as a comma separated list of field names. Multiple -s (or --select) options may be used.', argument: :required, multiple: true

        runner Commands::Taxa2lca
      end
    end

    def add_pept2prot_command
      @root_command.define_command('pept2prot') do
        usage 'pept2prot [options]'
        aliases :pp
        summary 'Fetch Uniprot records that match tryptic peptides.'
        description <<-EOS
        For each tryptic peptide the unipept pept2prot command retrieves from Unipept all Uniprot records whose protein sequence contains an exact matches to the tryptic peptide. The command expects a list of tryptic peptides that are passed

        - as separate command line arguments

        - in one or more text files that are passed as an argument to the -i option

        - to standard input

        The command will give priority to the first way tryptic peptides are passed, in the order as listed above. Text files and standard input should have one tryptic peptide per line.

        The unipept pept2prot subcommand yields Uniprot records as output.
        EOS

        flag :e, :equate, 'equate isoleucine (I) and leucine (L) when matching peptides'
        flag :a, :all, 'report all information fields of Uniprot records available in Unipept. Note that this may have a performance penalty.'
        option :s, :select, 'select the information fields to return. Selected fields are passed as a comma separated list of field names. Multiple -s (or --select) options may be used.', argument: :required, multiple: true
        option :x, :xml, 'download XML-formatted Uniprot records into the specified download-directory. ', argument: :required

        runner Commands::Pept2prot
      end
    end

    def add_taxonomy_command
      @root_command.define_command('taxonomy') do
        usage 'taxonomy [options]'
        aliases :tax
        summary 'Fetch taxonomic information from Unipept Taxonomy.'
        description <<-EOS
        The unipept taxonomy command yields information from the Unipept Taxonomy records for a given list of NCBI Taxonomy Identifiers. The Unipept Taxonomy is a cleaned up version of the NCBI Taxonomy, and its records are also records of the NCBI Taxonomy. The command expects a list of NCBI Taxonomy Identifiers that are passed

        - as separate command line arguments

        - in one or more text files that are passed as an argument to the -i option

        - to standard input

        The command will give priority to the first way NCBI Taxonomy Identifiers are passed, in the order as listed above. Text files and standard input should have one NCBI Taxonomy Identifier per line.

        The unipept taxonomy subcommand yields NCBI Taxonomy records as output.
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
