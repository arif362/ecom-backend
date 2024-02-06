class AddColumnAuthableIdAuthableTypeToAuthorizationKeys < ActiveRecord::Migration[6.0]
  def change
    add_column :authorization_keys, :authable_id, :integer
    add_column :authorization_keys, :authable_type, :string
  end
end
