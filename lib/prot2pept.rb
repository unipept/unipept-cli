require 'cri'

module Unipept
  class Prot2pept
    attr_reader :root_command
    attr_reader :valid_formats

    @root_command = Cri::Command.define do
      name 'prot2pept'
      summary 'Split protein sequences into peptides.'
      usage 'prot2pept [options]'
      description <<-EOS
      The prot2pept command splits each protein sequence into a list of peptides according to a given cleavage-pattern. The command expects a list of protein sequences that are passed to standard input.

      The input should have either one protein sequence per line or contain a FASTA formatted list of protein sequences. FASTA headers are preserved in the output, so that peptides can be bundled per protein sequence.

      EOS
      required :p, :pattern, 'specify cleavage-pattern (regex) as the pattern after which the next peptide will be cleaved (default: ([KR])([^P]) for tryptic peptides).'
      flag :h, :help, 'show help for this command' do |_value, cmd|
        puts cmd.help
        exit 0
      end
      run do |opts, _args, _cmd|
        pattern = opts.fetch(:pattern, '([KR])([^P])')

        # decide if we have FASTA input
        first_char = $stdin.getc
        $stdin.ungetc(first_char)
        if first_char == '>'
          # fasta mode!
          protein = ''
          while (line = $stdin.gets)
            if line.start_with? '>'
              puts Prot2pept.split(protein, pattern)
              protein = ''
              puts line
            else
              protein += line.chomp
            end
          end
          puts Prot2pept.split(protein, pattern)
        else
          $stdin.each_line do |prot|
            puts Prot2pept.split(prot, pattern)
          end
        end
      end
    end

    def self.split(protein, pattern)
      protein.gsub(/#{pattern}/, "\\1\n\\2").gsub(/#{pattern}/, "\\1\n\\2").split("\n").reject(&:empty?)
    end

    # Invokes the uniprot command-line tool with the given arguments.
    #
    # @param [Array<String>] args An array of command-line arguments
    #
    # @return [void]
    def self.run(args)
      @root_command.run(args)
    end
  end
end
