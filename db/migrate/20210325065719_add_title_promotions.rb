class AddTitlePromotions < ActiveRecord::Migration[6.0]
  def change
    add_column :promotions, :title, :string
  end
end
