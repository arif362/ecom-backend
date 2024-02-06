class AddedBkashNumberToPartnerAndRoutes < ActiveRecord::Migration[6.0]
  def change
    add_column :partners, :bkash_number, :string
    add_column :routes, :bkash_number, :string
  end
end
