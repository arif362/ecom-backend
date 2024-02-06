class AddStatusToCustomerCareAgent < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_care_agents, :status, :integer, default: 0
  end
end
