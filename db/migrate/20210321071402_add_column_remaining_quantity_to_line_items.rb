class AddColumnRemainingQuantityToLineItems < ActiveRecord::Migration[6.0]
  def change
    add_column :line_items, :remaining_quantity, :integer, default: 0
  end
end
