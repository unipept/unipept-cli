# == Schema Information
#
# Table name: sequences
#
#  id       :integer(4)      not null, primary key
#  sequence :string(50)      not null
#  lca      :integer(3)
#  lca_il   :integer(3)
#

class Sequence < ActiveRecord::Base
  
  has_many :peptides
  has_many :original_peptides, :foreign_key  => "original_sequence_id", :primary_key  => "id", :class_name   => 'Peptide'
  
  belongs_to :lca_t, :foreign_key  => "lca", :primary_key  => "id",  :class_name   => 'Taxon'
  belongs_to :lca_il_t, :foreign_key  => "lca_il", :primary_key  => "id",  :class_name   => 'Taxon'
  
  # SELECT DISTINCT lineages.* FROM unipept.peptides INNER JOIN unipept.uniprot_entries ON (uniprot_entries.id = peptides.uniprot_entry_id) INNER JOIN unipept.lineages ON (uniprot_entries.taxon_id = lineages.taxon_id) WHERE peptides.sequence_id = #{id}
  def lineages(equate_il = true, eager = false)
    if equate_il  
      if eager
        l = Lineage.select("lineages.*").joins(:uniprot_entries => :peptides).where("peptides.sequence_id = ?", id).uniq.includes(:name,  
                  :superkingdom_t, :kingdom_t, :subkingdom_t, :superphylum_t, :phylum_t, 
                  :subphylum_t, :superclass_t, :class_t, :subclass_t, :infraclass_t, 
                  :superorder_t, :order_t, :suborder_t, :infraorder_t, :parvorder_t, :superfamily_t, 
                  :family_t, :subfamily_t, :tribe_t, :subtribe_t, :genus_t, :subgenus_t, 
                  :species_group_t, :species_subgroup_t, :species_t, :subspecies_t, 
                  :varietas_t, :forma_t)
      else
        l = Lineage.select("lineages.*").joins(:uniprot_entries => :peptides).where("peptides.sequence_id = ?", id).uniq
      end
    else
      if eager
        l = Lineage.select("lineages.*").joins(:uniprot_entries => :peptides).where("peptides.original_sequence_id = ?", id).uniq.includes(:name, :superkingdom_t, :kingdom_t, :subkingdom_t, :superphylum_t, :phylum_t, :subphylum_t, :superclass_t, :class_t, :subclass_t, :infraclass_t, :superorder_t, :order_t, :suborder_t, :infraorder_t, :parvorder_t, :superfamily_t, :family_t, :subfamily_t, :tribe_t, :subtribe_t, :genus_t, :subgenus_t, :species_group_t, :species_subgroup_t, :species_t, :subspecies_t, :varietas_t, :forma_t)
      else
        l = Lineage.select("lineages.*").joins(:uniprot_entries => :peptides).where("peptides.original_sequence_id = ?", id).uniq
      end
    end
    return l
  end
  
  def calculate_lca(equate_il = true, return_taxon = false)
    if equate_il
      if lca_il.nil?
        temp = Lineage.calculate_lca(lineages(true))
        write_attribute(:lca_il, temp) unless temp==-1
        save
      end
      return lca_il_t if return_taxon
      return lca_il 
    else
      if lca.nil?
        temp = Lineage.calculate_lca(lineages(false))
        write_attribute(:lca, temp) unless temp==-1
        save
      end
      return lca_t if return_taxon
      return lca
    end
  end
      
  def self.batch_process(input, output = "output.csv")
    file = File.open(input, 'r')
    slice_size = 1
    data = file.readlines.each_slice(slice_size).to_a
    num_of_slices = data.size / slice_size
    current_slice = 0
    
    File.open(output, 'w') { |file| file.write(CSV.generate_line ["peptide"].concat(Lineage.ranks)) }
    
    for slice in data do
      csv_string = ""
      File.open("public/progress", 'w') { |file| file.write("batch process#" + (current_slice * 100 / num_of_slices).to_s) }

      query = slice.join("\n")
      data = query.upcase.gsub(/([KR])([^P])/,"\\1\n\\2").gsub(/([KR])([^P])/,"\\1\n\\2").lines.map(&:strip).to_a
      data_counts = Hash[data.group_by{|k| k}.map{|k,v| [k, v.length]}]
      data = data_counts.keys

      # build the resultset
      matches = Hash.new
      sequences = Sequence.find_all_by_sequence(data, :include => {:lca_t => {:lineage => [:superkingdom_t, :kingdom_t, :subkingdom_t, :superphylum_t, :phylum_t, :subphylum_t, :superclass_t, :class_t, :subclass_t, :infraclass_t, :superorder_t, :order_t, :suborder_t, :infraorder_t, :parvorder_t, :superfamily_t, :family_t, :subfamily_t, :tribe_t, :subtribe_t, :genus_t, :subgenus_t, :species_group_t, :species_subgroup_t, :species_t, :subspecies_t, :varietas_t, :forma_t]}})
      sequences.each do |sequence| # for every sequence in query
        lca_t = sequence.calculate_lca(false, true)
        unless lca_t.nil?
          matches[lca_t] = Array.new if matches[lca_t].nil?
          matches[lca_t] << sequence.sequence
        end
      end

      matches.each do |taxon, sequences| # for every match
        lca_l = taxon.lineage
        for sequence in sequences do
          csv_string += CSV.generate_line [sequence].concat(lca_l.to_a)
        end
      end
      File.open(output, 'a') { |file| file.write(csv_string) }
      current_slice += 1
    end
    File.open("public/progress", 'w') { |file| file.write("batch process#100") }
  end                  
end
