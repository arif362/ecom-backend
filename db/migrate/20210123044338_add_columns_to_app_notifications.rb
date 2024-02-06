class AddColumnsToAppNotifications < ActiveRecord::Migration[6.0]
  def change
    add_column :app_notifications, :title, :string
  end
end
