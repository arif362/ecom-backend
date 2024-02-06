class AddLeafCategoryProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :leaf_category_id, :integer
  end
end
