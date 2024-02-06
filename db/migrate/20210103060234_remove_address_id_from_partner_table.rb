class RemoveAddressIdFromPartnerTable < ActiveRecord::Migration[6.0]
  def change
    remove_column :partners, :address_id
  end
end
