class AddBnDetailsOnNotifications < ActiveRecord::Migration[6.0]
  def change
    add_column :notifications, :bn_details, :text
  end
end
