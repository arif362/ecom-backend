class AddQcColumnsToLineItems < ActiveRecord::Migration[6.0]
  def change
    add_column :line_items, :reconcilation_status, :integer, default: 0
  end
end
