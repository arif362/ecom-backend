class AddColsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :gender, :integer
    add_column :users, :age, :integer
    add_column :users, :otp, :string
    add_column :users, :registerable_type, :string
    add_column :users, :registerable_id, :integer
  end
end
