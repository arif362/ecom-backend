class RenamePasswordToEncryptedPasswordInWarehouses < ActiveRecord::Migration[6.0]
  def change
    rename_column :warehouses, :password, :encrypted_password
  end
end
