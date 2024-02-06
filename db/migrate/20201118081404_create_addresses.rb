class CreateAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :addresses do |t|
      t.integer :district_id, null: false
      t.integer :thana_id, null: false
      t.integer :area_id, null: false
      t.string :name
      t.string :bn_name
      t.string :address_line, null: false
      t.string :bn_address_line, null: false
      t.string :zip_code, null: false
      t.string :bn_zip_code, null: false
      t.string :phone, null: false
      t.string :bn_phone, null: false
      t.string :alternative_phone
      t.string :bn_alternative_phone
      t.boolean :is_deleted, default: false
      t.timestamps
    end
  end
end
