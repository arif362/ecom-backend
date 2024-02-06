class AddPromotionIdToShopothLineItems < ActiveRecord::Migration[6.0]
  def change
    add_column :shopoth_line_items, :promotion_id, :integer
  end
end
