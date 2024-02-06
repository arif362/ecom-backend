class AddUserTypeToThirdPartyUser < ActiveRecord::Migration[6.0]
  def change
    add_column :third_party_users, :user_type, :integer, default: 0
  end
end
