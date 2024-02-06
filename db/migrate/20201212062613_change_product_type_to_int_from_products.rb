class ChangeProductTypeToIntFromProducts < ActiveRecord::Migration[6.0]
  def change
    remove_column :products, :product_type
    add_column :products, :product_type, :integer, default: 0
  end
end
