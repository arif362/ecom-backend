class CreateThirdPartyUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :third_party_users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone, null: false
      t.string :tenant
      t.string :encrypted_password, null: false

      t.timestamps
    end
  end
end
