class AddCategoryToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :category, :integer, default: 0
  end
end
