class WarehouseVariantsLocation < ApplicationRecord
  audited
  belongs_to :location
  belongs_to :warehouse_variant
end
