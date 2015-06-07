require 'cri'
require 'typhoeus'

module Unipept
  class Uniprot
    attr_reader :root_command
    attr_reader :valid_formats

    valid_formats = Set.new %w(fasta txt xml rdf gff sequence)
    @root_command = Cri::Command.new_basic_root.modify do
      name 'uniprot'
      summary 'Command line interface to Uniprot web services.'
      usage 'uniprot [options]'
      description <<-EOS
      The uniprot command is a command line wrapper around the Uniprot web services. The command expects a list of Uniprot Accession Numbers that are passed

      - as separate command line arguments

      - to standard input

      The command will give priority to the first way Uniprot Accession Numbers are passed, in the order as listed above. The standard input should have one Uniprot Accession Number per line.

      The uniprot command yields just the protein sequences as a default, but can return several formats.
      EOS
      required :f, :format, 'specify output format (available: ' + valid_formats.to_a.join(', ') + ') (default: sequence)'
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

    # Fetches a Uniprot record from the uniprot website with the given accession
    # number in the requested format.
    #
    # @param [String] accession The accession number of the record to fetch
    #
    # @param [String] format The format of of the record. If the format is 'sequence', the sequence will be returned in as a single line
    #
    # @return [String] The requested Uniprot record in the requested format
    def self.get_uniprot_entry(accession, format)
      if format == 'sequence'
        resp = Typhoeus.get("http://www.uniprot.org/uniprot/#{accession}.fasta")
        if resp.success?
          resp.response_body.lines.map(&:chomp)[1..-1].join('')
        end
      else
        # other format has been specified, just download and output
        resp = Typhoeus.get("http://www.uniprot.org/uniprot/#{accession}.#{format}")
        if resp.success?
          resp.response_body
        end
      end
    end
  end
end
