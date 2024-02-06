class ChangeShopothLineItemNullFromReturnShopothLineItem < ActiveRecord::Migration[6.0]
  def change
    change_column_null :return_shopoth_line_items, :shopoth_line_item_id, true
  end
end
