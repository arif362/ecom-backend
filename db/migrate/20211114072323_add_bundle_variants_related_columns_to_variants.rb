class AddBundleVariantsRelatedColumnsToVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :variants, :parent_id, :integer, { null: true, after: :deleted_at, default: nil }
    add_column :variants, :quantity, :decimal, { precision: 10, scale: 2, default: 0.0 }
  end
end
