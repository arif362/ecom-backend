class RemoveUniqueIdSupplierVariant < ActiveRecord::Migration[6.0]
  def change
    remove_column :suppliers_variants, :unique_id
  end
end
