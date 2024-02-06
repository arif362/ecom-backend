class AddCategoryFieldInConfigurationTable < ActiveRecord::Migration[6.0]
  def change
    add_column :configurations, :category, :integer, default: 0
  end
end
