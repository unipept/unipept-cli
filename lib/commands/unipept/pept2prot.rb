require_relative 'api_runner'

module Unipept::Commands
  class Pept2prot < ApiRunner
    def initialize(args, opts, cmd)
      if args[:meganize]
        args[:all] = true
        args[:select] = ['peptide,refseq_protein_ids']
        args[:format] = 'blast'
      end
      super
    end

    def required_fields
      ['peptide']
    end

    def default_batch_size
      if options[:all]
        5
      else
        10
      end
    end
  end
end
