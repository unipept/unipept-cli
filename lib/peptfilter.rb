require 'cri'

module Unipept
  class Peptfilter
    attr_reader :root_command

    @root_command = Cri::Command.new_basic_root.modify do
      name 'peptfilter'
      summary 'Filter peptides based on specific criteria.'
      usage 'peptfilter [options]'
      description <<-EOS
      The peptfilter command filters a list of peptides according to specific criteria. The command expects a list of peptides that are passed to standard input.

      The input should have one peptide per line. FASTA headers are preserved in the output, so that peptides remain bundled.
      EOS
      # flag :u, :unique, "filter duplicate peptides."
      required nil, :minlen, 'only retain tryptic peptides that have at least min (default: 5) amino acids.'
      required nil, :maxlen, 'only retain tryptic peptides that have at most max (default: 50) amino acids.'
      required :l, :lacks, 'only retain tryptic peptides that lack all amino acids from the string of residues.'
      required :c, :contains, 'only retain tryptic peptides that contain all amino acids from the string of residues.'
      run do |opts, _args, _cmd|
        minlen = opts.fetch(:minlen, '5').to_i
        maxlen = opts.fetch(:maxlen, '50').to_i
        lacks = opts.fetch(:lacks, '').chars.to_a
        contains = opts.fetch(:contains, '').chars.to_a
        $stdin.each_line do |pept|
          # FASTA headers
          if pept.start_with? '>'
            puts pept
            next
          end

          pept = pept.chomp
          if Peptfilter.filter(pept, minlen, maxlen, lacks, contains)
            puts pept
          end
        end
      end
    end

    # Invokes the peptfilter command-line tool with the given arguments.
    #
    # @param [Array<String>] args An array of command-line arguments
    #
    # @return [void]
    def self.run(args)
      @root_command.run(args)
    end

    # Checks if a peptide satisfies the min length, max length, lacks and contains requirements.
    # Returns true if
    # - the peptide length is equal or higher than min
    # - the peptide length is equal or lower than max
    # - the peptide doesn't contain any of the amino acids in lacks
    # - the peptide contains all of the amino acids in contains
    #
    # @param [String] peptide The peptide to check
    #
    # @param [Integer] min The minimal length requirement
    #
    # @param [Integer] max The maximal length requirement
    #
    # @param [Array<String>] lacks The forbidden amino acids
    #
    # @param [Array<String>] contains The required amino acids
    #
    # @return [Boolean] true if the peptide satisfies all requirements
    def self.filter(peptide, min, max, lacks, contains)
      filter_length(peptide, min, max) &&
        filter_lacks(peptide, lacks) &&
        filter_contains(peptide, contains)
    end

    # Checks if a peptide satisfies the min length and max length requirements.
    # Returns true if
    # - the peptide length is equal or higher than min
    # - the peptide length is equal or lower than max
    #
    # @param [String] peptide The peptide to check
    #
    # @param [Integer] min The minimal length requirement
    #
    # @param [Integer] max The maximal length requirement
    #
    # @return [Boolean] true if the peptide satisfies all requirements
    def self.filter_length(peptide, min, max)
      peptide.length >= min && peptide.length <= max
    end

    # Checks if a peptide satisfies lacks requirement.
    # Returns true if
    # - the peptide doesn't contain any of the amino acids in lacks
    #
    # @param [String] peptide The peptide to check
    #
    # @param [Array<String>] lacks The forbidden amino acids
    #
    # @return [Boolean] true if the peptide satisfies all requirements
    def self.filter_lacks(peptide, lacks)
      (peptide.chars.to_a & lacks).size == 0
    end

    # Checks if a peptide satisfies the contains requirement.
    # Returns true if
    # - the peptide contains all of the amino acids in contains
    #
    # @param [String] peptide The peptide to check
    #
    # @param [Array<String>] contains The required amino acids
    #
    # @return [Boolean] true if the peptide satisfies all requirements
    def self.filter_contains(peptide, contains)
      (peptide.chars.to_a & contains).size == contains.size
    end
  end
end
