class DropSupplierVariantAssociateTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :supplier_variants
    drop_table :supplier_variant_values
  end
end
