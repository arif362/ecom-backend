class CreateVariants < ActiveRecord::Migration[6.0]
  def change
    create_table :variants do |t|
      t.integer :sku
      t.float :weight
      t.float :height
      t.float :width
      t.float :depth
      t.datetime :deleted_at
      t.integer :product_id
    end
  end
end
