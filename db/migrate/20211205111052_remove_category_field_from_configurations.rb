class RemoveCategoryFieldFromConfigurations < ActiveRecord::Migration[6.0]
  def change
    remove_column :configurations, :category, :integer
    rename_column :configurations, :name, :key
  end
end
