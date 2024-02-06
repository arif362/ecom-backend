class CreatePartners < ActiveRecord::Migration[6.0]
  def change
    create_table :partners do |t|
      t.integer :address_id, null: false
      t.string :name, null: false
      t.string :bn_name, null: false
      t.string :password_digest
      t.string :phone
      t.string :email
      t.integer :status, default: 0
      t.timestamps
    end
  end
 end
