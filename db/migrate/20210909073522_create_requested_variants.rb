class CreateRequestedVariants < ActiveRecord::Migration[6.0]
  def change
    create_table :requested_variants do |t|
      t.integer :variant_id, null: false
      t.integer :user_id, null: false
      t.integer :warehouse_id, null: false

      t.timestamps
    end
  end
end
