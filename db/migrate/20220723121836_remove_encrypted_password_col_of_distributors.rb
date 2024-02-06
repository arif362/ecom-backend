class RemoveEncryptedPasswordColOfDistributors < ActiveRecord::Migration[6.0]
  def change
    remove_column :distributors, :encrypted_password, :string
  end
end
