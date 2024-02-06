class AddIndexToSuppliersVariants < ActiveRecord::Migration[6.0]
  def change
    add_index :suppliers_variants, [:variant_id, :supplier_id], unique: true
  end
end
