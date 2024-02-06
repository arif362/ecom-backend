class AddCategoryColumnsToRetailerAssistants < ActiveRecord::Migration[6.0]
  def change
    add_column :retailer_assistants, :category, :integer, default: 0
  end
end
