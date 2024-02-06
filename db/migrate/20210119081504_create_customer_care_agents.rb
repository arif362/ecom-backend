class CreateCustomerCareAgents < ActiveRecord::Migration[6.0]
  def change
    create_table :customer_care_agents do |t|
      t.string :name, default: "", null: false
      t.string :phone, default: "", null: false
      t.string :email, default: "", null: false
      t.string :encrypted_password, default: "", null: false
      t.integer :warehouse_id
      t.timestamps
    end
    add_index :customer_care_agents, :email, unique: true
  end
end
