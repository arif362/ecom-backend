class RemoveFields < ActiveRecord::Migration[6.0]
  def change
    drop_table :logistics
    drop_table :shopoth_vehicles
    remove_column :partners, :outlet_name, :string
    remove_column :dh_purchase_orders, :bn_quantity, :decimal
    remove_column :wh_purchase_orders, :bn_quantity, :decimal
    remove_column :wh_purchase_orders, :bn_total_price, :decimal
    remove_column :dh_purchase_orders, :bn_total_price, :decimal
    remove_column :addresses, :bn_zip_code, :string
  end
end
