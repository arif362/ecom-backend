class AddIsLoyalToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :is_loyal, :boolean, default: false
  end
end
