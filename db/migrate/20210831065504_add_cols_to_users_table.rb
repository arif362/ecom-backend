class AddColsToUsersTable < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :full_name, :string, default: ''
    add_column :users, :date_of_birth, :date
  end
end
