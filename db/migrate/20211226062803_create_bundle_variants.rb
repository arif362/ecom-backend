class CreateBundleVariants < ActiveRecord::Migration[6.0]
  def change
    create_table :bundle_variants do |t|
      t.integer :bundle_id, null: false
      t.integer :variant_id, null: false
      t.integer :quantity, default: 0

      t.timestamps
    end
  end
end
