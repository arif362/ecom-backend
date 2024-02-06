class AddUserToAddress < ActiveRecord::Migration[6.0]
  def change
    add_reference :addresses, :user, foreign_key: true, index: true,
                  optional: true
    add_column :addresses, :default_address, :boolean, default: false
  end
end
