class AddIsb2bPartners < ActiveRecord::Migration[6.0]
  def change
    add_column :partners, :is_b2b, :boolean, default: false
  end
end
