class AddUniqueIdColumns < ActiveRecord::Migration[6.0]
  def change
    add_column :suppliers, :unique_id, :string
    add_column :categories, :unique_id, :string
    add_column :attribute_sets, :unique_id, :string
    add_column :product_attributes, :unique_id, :string
    add_column :product_attribute_values, :unique_id, :string
    add_column :brands, :unique_id, :string
    add_column :products, :unique_id, :string
    add_column :variants, :unique_id, :string
    add_column :wh_purchase_orders, :master_po_id, :string
    add_column :wh_purchase_orders, :unique_id, :string
    add_column :suppliers_variants, :unique_id, :string
  end
end
