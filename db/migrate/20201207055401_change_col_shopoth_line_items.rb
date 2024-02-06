class ChangeColShopothLineItems < ActiveRecord::Migration[6.0]
  def change
    remove_index :shopoth_line_items, :product_id
    remove_column :shopoth_line_items, :product_id, :bigint
    add_column :shopoth_line_items, :variant_id, :integer
    add_index :shopoth_line_items, :variant_id
  end
end
