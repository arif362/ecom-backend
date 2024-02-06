class AddDiscountTypeInCarts < ActiveRecord::Migration[6.0]
  def change
    add_column :carts, :cart_dis_type, :string unless column_exists? :carts, :cart_dis_type
    remove_column :carts, :shopoth_line_item_discounts, :decimal if column_exists? :carts, :shopoth_line_item_discounts
  end
end
