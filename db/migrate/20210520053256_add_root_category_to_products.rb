class AddRootCategoryToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :root_category_id, :integer
  end
end
