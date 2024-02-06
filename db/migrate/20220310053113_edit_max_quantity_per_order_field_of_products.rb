class EditMaxQuantityPerOrderFieldOfProducts < ActiveRecord::Migration[6.0]
  def change
    remove_column :products, :max_quantity_per_order, :integer
    add_column :products, :max_quantity_per_order, :integer
  end
end
