class RemoveVariantAndSupplierIndexFromSuppliersVariants < ActiveRecord::Migration[6.0]
  def change
    remove_index :suppliers_variants, column: %i(variant_id supplier_id)
  end
end
