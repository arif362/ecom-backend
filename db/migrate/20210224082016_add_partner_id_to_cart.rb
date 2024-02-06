class AddPartnerIdToCart < ActiveRecord::Migration[6.0]
  def change
    add_column :carts, :partner_id, :integer
  end
end
