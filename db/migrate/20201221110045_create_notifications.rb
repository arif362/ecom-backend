class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.text :details
      t.boolean :read, default: false, null: false
      t.references :user, foreign_key: true, null: false

      t.timestamps
    end
  end
end
