require 'typhoeus'

module Unipept::Commands
  class Uniprot
    attr_reader :root_command
    attr_reader :valid_formats

    valid_formats = Set.new %w(fasta txt xml rdf gff sequence)
    @root_command = Cri::Command.define do
      name 'uniprot'
      summary 'Command line interface to UniProt web services.'
      usage 'uniprot [options]'
      description <<-EOS
      The uniprot command fetches UniProt entries from the UniProt web services. The command expects a list of UniProt Accession Numbers that are passed

      - as separate command line arguments

      - to standard input

      The command will give priority to the first way UniProt Accession Numbers are passed, in the order as listed above. The standard input should have one UniProt Accession Number per line.

      The uniprot command yields just the protein sequences as a default, but can return several formats.
      EOS
      required :f, :format, 'specify output format (available: ' + valid_formats.to_a.join(', ') + ') (default: sequence)'
      flag :h, :help, 'show help for this command' do |_value, cmd|
        puts cmd.help
        exit 0
      end
      run do |opts, args, _cmd|
        format = opts.fetch(:format, 'sequence')
        unless valid_formats.include? format
          $stderr.puts format + ' is not a valid output format. Available formats are: ' + valid_formats.to_a.join(', ')
          exit 1
        end
        iterator = args.empty? ? $stdin.each_line : args
        iterator.each do |accession|
          puts Uniprot.get_uniprot_entry(accession.chomp, format)
        end
      end
    end

    # Invokes the uniprot command-line tool with the given arguments.
    #
    # @param [Array<String>] args An array of command-line arguments
    #
    # @return [void]
    def self.run(args)
      @root_command.run(args)
    end

    # Fetches a UniProt entry from the UniProt website with the given accession
    # number in the requested format.
    #
    # @param [String] accession The accession number of the record to fetch
    #
    # @param [String] format The format of of the record. If the format is 'sequence', the sequence will be returned in as a single line
    #
    # @return [String] The requested UniProt entry in the requested format
    def self.get_uniprot_entry(accession, format)
      if format == 'sequence'
        get_uniprot_entry(accession, 'fasta').lines.map(&:chomp)[1..-1].join('')
      else
        # other format has been specified, just download and output
        resp = Typhoeus.get("https://www.uniprot.org/uniprot/#{accession}.#{format}")
        resp.response_body if resp.success?
      end
    end
  end
end
