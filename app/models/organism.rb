# == Schema Information
#
# Table name: organisms
#
#  id         :integer(4)      not null, primary key
#  name       :string(512)     not null
#  taxon_id   :integer(4)      not null
#  species_id :integer(4)      not null
#  genus_id   :integer(4)      not null
#

class Organism < ActiveRecord::Base
  attr_accessible nil
  
  has_many :peptides 
  belongs_to :scientific_name,  :foreign_key  => "taxon_id", 
                                :primary_key  => "tax_id", 
                                :class_name   => 'TaxonName'
  belongs_to :species_name,     :foreign_key  => "species_id", 
                                :primary_key  => "tax_id", 
                                :class_name   => 'TaxonName'
  belongs_to :genus_name,       :foreign_key  => "genus_id", 
                                :primary_key  => "tax_id", 
                                :class_name   => 'TaxonName'
  
  validates :name,  :presence   => true
  validates :taxon_id,  :presence   => true
  validates :species_id,  :presence   => true
  validates :genus_id,  :presence   => true
  
end