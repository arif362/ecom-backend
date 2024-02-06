class RemoveColumnFromSupplierVariantTable < ActiveRecord::Migration[6.0]
  def change
    remove_column :supplier_variants, :variant_id unless column_exists? :supplier_variants, :variant_id
    remove_column :supplier_variants, :supplier_price unless column_exists? :supplier_variants, :supplier_price
  end
end
