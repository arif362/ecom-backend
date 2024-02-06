class WarehouseStorage < ApplicationRecord
  has_many :storage_variants
  belongs_to :warehouse
  validates :warehouse_id, :name, :bn_name, :area, :location, presence: true
end
