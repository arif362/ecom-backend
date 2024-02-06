class AddColumnsToReturnShopothLineItems < ActiveRecord::Migration[6.0]
  def change
    add_column :return_shopoth_line_items, :reason, :integer, default: 0
    add_column :return_shopoth_line_items, :description, :string
    add_column :return_shopoth_line_items, :qr_code, :string
  end
end
