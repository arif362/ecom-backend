class WarehouseCollectHistory < ApplicationRecord
  belongs_to :warehouse

  def self.find_collect_history(warehouse, date)
    where(warehouse_id: warehouse.id, collect_date: date)
  end
end
