class CreateAppNotification < ActiveRecord::Migration[6.0]
  def change
    create_table :app_notifications do |t|
      t.string :message, default: ''
      t.boolean :read, default: false
      t.references :notifiable, polymorphic: true, null: false
      t.timestamps
    end
  end
end
