class StorageVariant < ApplicationRecord
  belongs_to :warehouse_storage
  belongs_to :variant
  validates :warehouse_storage_id, :variant_id, :quantity, presence: true
end
