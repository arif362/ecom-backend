class AddRaTrackingFieldsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :is_app_download, :boolean
    add_column :users, :has_smart_phone, :boolean
    add_column :users, :partner_id, :integer
  end
end
