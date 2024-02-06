class AddColInPartner < ActiveRecord::Migration[6.0]
  def change
    add_column :partners, :tsa_id, :integer
    add_column :partners, :route_id, :integer
    add_column :partners, :retailer_code, :string
    add_column :partners, :partner_code, :string
    add_column :partners, :region, :string
    add_column :partners, :area, :string
    add_column :partners, :territory, :string
    add_column :partners, :outlet_name, :string
    add_column :partners, :owner_name, :string
    add_column :partners, :cluster_name, :string
    add_column :partners, :sub_channel, :string
    add_column :partners, :latitude, :decimal, precision: 15, scale: 12, default: 0.0
    add_column :partners, :longitude, :decimal, precision: 15, scale: 12, default: 0.0
  end
end
