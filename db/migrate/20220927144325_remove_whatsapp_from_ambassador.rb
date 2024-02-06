class RemoveWhatsappFromAmbassador < ActiveRecord::Migration[6.0]
  def up
    remove_column :ambassadors, :whatsapp
  end

  def down
    add_column :ambassadors, :whatsapp, :string
  end
end
