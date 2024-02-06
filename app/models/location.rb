class Location < ApplicationRecord
  audited
  belongs_to :warehouse
  has_many :warehouse_variants_locations
  has_many :warehouse_variants, through: :warehouse_variants_locations
  has_many :variants, through: :warehouse_variants
  has_many :line_items
  has_many :shopoth_line_items

  validates :code, presence: true, uniqueness: true
end
