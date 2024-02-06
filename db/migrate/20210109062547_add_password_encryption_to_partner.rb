class AddPasswordEncryptionToPartner < ActiveRecord::Migration[6.0]
  def change
    add_column :partners, :encrypted_password, :string, default: "", null: false
    remove_column :partners, :password_digest
  end
end
