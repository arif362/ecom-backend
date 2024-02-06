class AddIsDeletedToSuppliersVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :suppliers_variants, :is_deleted, :boolean, default: false
  end
end
