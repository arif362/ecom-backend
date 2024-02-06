class RemoveColAddresses < ActiveRecord::Migration[6.0]
  def change
    change_column_null :addresses, :bn_address_line, true
  end
end
