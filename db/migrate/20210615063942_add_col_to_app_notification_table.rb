class AddColToAppNotificationTable < ActiveRecord::Migration[6.0]
  def change
    add_column :app_notifications, :bn_title, :string, default: ''
    add_column :app_notifications, :bn_message, :string, default: ''
  end
end
