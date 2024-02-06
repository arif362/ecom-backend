class AddSendQuantityColToLineItem < ActiveRecord::Migration[6.0]
  def change
    add_column :line_items, :send_quantity, :integer, default: 0
  end
end
