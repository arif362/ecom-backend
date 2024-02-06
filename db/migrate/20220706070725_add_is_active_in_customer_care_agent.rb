class AddIsActiveInCustomerCareAgent < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_care_agents, :is_active, :boolean, default: true
  end
end
