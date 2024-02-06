class DropReturnShopothLineItem < ActiveRecord::Migration[6.0]
  def change
    drop_table :return_shopoth_line_items
  end
end
