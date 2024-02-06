class AddAttributesAddress < ActiveRecord::Migration[6.0]
  def change
    add_column :addresses, :addressable_id, :integer
    add_column :addresses, :addressable_type, :string
  end
end
