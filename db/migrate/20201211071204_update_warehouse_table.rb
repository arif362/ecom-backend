class UpdateWarehouseTable < ActiveRecord::Migration[6.0]
  def change
    add_column :warehouses, :phone, :string
    change_column :warehouses, :capacity, :decimal, precision: 10, scale: 2
    change_column_default :warehouses, :warehouse_type, 'distribution_house'
  end
end
