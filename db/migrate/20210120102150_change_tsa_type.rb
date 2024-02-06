class ChangeTsaType < ActiveRecord::Migration[6.0]
  def change
    change_column :partners, :tsa_id, :string
  end
end
