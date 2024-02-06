class AddColumnsToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :product_type, :string
  end
end
