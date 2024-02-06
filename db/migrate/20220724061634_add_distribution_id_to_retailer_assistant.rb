class AddDistributionIdToRetailerAssistant < ActiveRecord::Migration[6.0]
  def change
    add_column :retailer_assistants, :distributor_id, :integer
  end
end
