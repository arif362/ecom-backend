class CreateDeliveryPreferences < ActiveRecord::Migration[6.0]
  def change
    create_table :delivery_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :partner_id
      t.integer :pay_type
      t.integer :shipping_type
      t.boolean :is_default
      t.timestamps
    end
  end
end
