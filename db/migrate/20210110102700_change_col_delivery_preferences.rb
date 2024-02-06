class ChangeColDeliveryPreferences < ActiveRecord::Migration[6.0]
  def change
    remove_column :delivery_preferences, :is_default, :boolean
    add_column :delivery_preferences, :default, :boolean, default: false, null: false
  end
end
