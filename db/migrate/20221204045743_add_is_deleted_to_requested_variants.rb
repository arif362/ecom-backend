class AddIsDeletedToRequestedVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :requested_variants, :is_deleted, :boolean, default: false
  end
end
