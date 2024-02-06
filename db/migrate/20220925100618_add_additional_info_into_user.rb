class AddAdditionalInfoIntoUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :whatsapp, :string
    add_column :users, :viber, :string
    add_column :users, :imo, :string
    add_column :users, :nid, :string
    add_column :users, :home_address, :string
  end
end
