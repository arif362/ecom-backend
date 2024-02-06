class AddColsToRetailerAssistants < ActiveRecord::Migration[6.0]
  def change
    add_column :retailer_assistants, :father_name, :string
    add_column :retailer_assistants, :experience, :string
    add_column :retailer_assistants, :education, :string
    add_column :retailer_assistants, :nid, :string
    add_column :retailer_assistants, :tech_skill, :string
    add_column :retailer_assistants, :date_of_birth, :timestamp
    add_column :retailer_assistants, :warehouse_id, :integer
    add_index :retailer_assistants, :warehouse_id
  end
end
