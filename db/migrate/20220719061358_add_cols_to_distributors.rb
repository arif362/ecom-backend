class AddColsToDistributors < ActiveRecord::Migration[6.0]
  def change
    add_column :distributors, :email, :string, default: ''
    add_column :distributors, :encrypted_password, :string
    add_column :distributors, :phone, :string, default: ''
    add_column :distributors, :address, :string, default: ''
    add_column :distributors, :code, :string, default: ''
    add_column :distributors, :status, :integer, default: 0
  end
end
