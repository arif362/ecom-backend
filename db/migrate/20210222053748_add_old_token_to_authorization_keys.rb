class AddOldTokenToAuthorizationKeys < ActiveRecord::Migration[6.0]
  def change
    add_column :authorization_keys, :old_token, :string
  end
end