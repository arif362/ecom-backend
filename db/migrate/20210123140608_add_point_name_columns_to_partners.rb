class AddPointNameColumnsToPartners < ActiveRecord::Migration[6.0]
  def change
    add_column :routes, :sr_point, :string
    add_column :routes, :sr_name, :string
  end
end
