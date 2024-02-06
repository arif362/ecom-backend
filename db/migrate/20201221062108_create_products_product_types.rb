class CreateProductsProductTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :products_product_types do |t|
      t.integer :product_id
      t.integer :product_type_id

      t.timestamps
    end
  end
end
