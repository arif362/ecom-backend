class CreateUserPreferences < ActiveRecord::Migration[6.0]
  def change
    create_table :user_preferences do |t|
      t.references :user, null: false, foreign_key: true, unique: true
      t.integer :default_delivery_method, default: 0
      t.integer :mail_notification, default: 0
      t.integer :smart_notification, default: 0
      t.integer :cellular_notification, default: 0
      t.integer :subscription, default: 0
      t.timestamps
    end
  end
end
