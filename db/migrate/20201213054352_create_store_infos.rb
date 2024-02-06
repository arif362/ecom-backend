class CreateStoreInfos < ActiveRecord::Migration[6.0]
  def change
    create_table :store_infos do |t|
      t.string :official_email, null: false
      t.text :contact_address, null: false
      t.integer :contact_number, null: false
      t.string :footer_bottom
      t.integer :social_link_id
      t.timestamps
    end
  end
end
