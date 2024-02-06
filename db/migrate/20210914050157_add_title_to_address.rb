class AddTitleToAddress < ActiveRecord::Migration[6.0]
  def change
    add_column :addresses, :title, :string, default: 'others'
  end
end
