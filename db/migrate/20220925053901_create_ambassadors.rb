class CreateAmbassadors < ActiveRecord::Migration[6.0]
  def change
    create_table :ambassadors do |t|
      t.bigint :user_id
      t.string :bkash_number
      t.string :whatsapp
      t.string :preferred_name
      t.boolean :is_deleted, default: false
      t.timestamps
    end
  end
end
