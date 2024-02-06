class AddProductSpecification < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :product_specifications, :text
  end
end
