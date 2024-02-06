class AddColumnsToSupplierVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :supplier_variants, :variant_id, :integer
    add_column :supplier_variants, :supplier_price, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
