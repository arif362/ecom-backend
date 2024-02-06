class AddPointColumnToPartner < ActiveRecord::Migration[6.0]
  def change
    add_column :partners, :point, :text
  end
end
