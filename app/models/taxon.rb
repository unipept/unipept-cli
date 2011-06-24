# == Schema Information
#
# Table name: taxons
#
#  id        :integer(3)      not null, primary key
#  name      :string(256)     not null
#  rank      :string(0)
#  parent_id :integer(3)
#

class Taxon < ActiveRecord::Base
  attr_accessible nil
  
  scope :with_genome, select("DISTINCT taxons.*").joins("RIGHT JOIN uniprot_entries ON taxons.id = uniprot_entries.taxon_id")
  
end
