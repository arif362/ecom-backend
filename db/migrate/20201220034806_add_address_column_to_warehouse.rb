class AddAddressColumnToWarehouse < ActiveRecord::Migration[6.0]
  def change
    add_column :warehouses, :address, :string
    add_column :warehouses, :is_deleted, :boolean, default: false
    change_column_default :warehouses, :warehouse_type, 'distribution'
  end
end
