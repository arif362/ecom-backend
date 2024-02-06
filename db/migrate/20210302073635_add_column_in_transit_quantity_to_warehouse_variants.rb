class AddColumnInTransitQuantityToWarehouseVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :warehouse_variants, :in_transit_quantity, :integer, default: 0
  end
end
