class Api::ApiController < ApplicationController

  respond_to :json

  before_filter :set_params, only: [:single, :lca, :pept2pro]

  def set_params
    @sequences = params[:sequences].map(&:chomp)
    @equate_il = (!params[:equate_il].blank? && params[:equate_il] == 'true')
    @full_lineage = (!params[:full_lineage].blank? && params[:full_lineage] == 'true')
  end

  def single
    @result = {}
    @sequences.map do |s|
      peptides = Sequence.single_search(s.upcase, @equate_il)
      if peptides
        entries = peptides.peptides.map(&:uniprot_entry)

        @result[s] = Taxon.includes(:lineage).find(entries.map(&:taxon_id))
      end
    end

    respond_with(@result)
  end

  def lca
    @result = {}
    @sequences.map do |s|
      sequence = Sequence.single_search(s.upcase, @equate_il)
      name = @equate_il ? :lca_il : :lca
      @result[s] = Taxon.includes(:lineage).find(sequence.send(name)) if sequence
    end

    respond_with(@result)
  end

  def taxa2lca
    @taxon_ids = params[:taxon_ids].map(&:chomp)
    @equate_il = (!params[:equate_il].blank? && params[:equate_il] == 'true')

    name = @equate_il ? :lca_il : :lca
    @result = Taxon.includes(:lineage).find(@taxon_ids)

    respond_with(@result)
  end

  def pept2pro
    @result = {}
    @sequences.map do |s|
      peptides = Sequence.single_search(s.upcase, @equate_il)
      @result[s] =  peptides.peptides.map(&:uniprot_entry) if peptides
    end

    respond_with(@result)
  end

end
