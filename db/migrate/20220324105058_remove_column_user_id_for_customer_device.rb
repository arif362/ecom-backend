class RemoveColumnUserIdForCustomerDevice < ActiveRecord::Migration[6.0]
  def change
    remove_column :customer_devices, :user_id
  end
end
