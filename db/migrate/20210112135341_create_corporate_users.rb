class CreateCorporateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :corporate_users do |t|
      t.string :name, default: "", null: false
      t.string :phone, default: "", null: false
      t.string :email, default: "", null: false
      t.string :encrypted_password, default: "", null: false
      t.integer :warehouse_id

      t.timestamps
    end
    add_index :corporate_users, :email, unique: true
  end
end
