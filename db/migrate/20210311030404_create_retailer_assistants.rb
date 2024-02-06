class CreateRetailerAssistants < ActiveRecord::Migration[6.0]
  def change
    create_table :retailer_assistants do |t|
      t.string :name, null: false
      t.string :phone, null: false
      t.string :encrypted_password, null: false, default: ''
      t.string :email
      t.integer :status, default: 1
      t.string :bn_name
      t.timestamps
    end
  end
end
