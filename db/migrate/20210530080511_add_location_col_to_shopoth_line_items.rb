class AddLocationColToShopothLineItems < ActiveRecord::Migration[6.0]
  def change
    add_column :shopoth_line_items, :location_id, :integer
  end
end
