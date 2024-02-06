class AddEcomNotifiableInNotificationTable < ActiveRecord::Migration[6.0]
  def change
    add_column :notifications, :user_notifiable_id, :integer
    add_column :notifications, :user_notifiable_type, :string
  end
end
