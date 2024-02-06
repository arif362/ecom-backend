class RequestedVariant < ApplicationRecord
  belongs_to :warehouse
  belongs_to :user
  belongs_to :variant

  after_create :create_warehouse_variant

  private

  def create_warehouse_variant
    WarehouseVariant.find_or_create_by(warehouse: warehouse, variant: variant )
  end
end
