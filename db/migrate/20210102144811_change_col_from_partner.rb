class ChangeColFromPartner < ActiveRecord::Migration[6.0]
  def change
    remove_column :partners, :bn_name, :string
    add_column :partners, :bn_name, :string
  end
end
