class AddLocationIdToLineItems < ActiveRecord::Migration[6.0]
  def change
    add_column :line_items, :location_id, :integer
  end
end
