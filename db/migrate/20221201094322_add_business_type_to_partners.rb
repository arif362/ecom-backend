class AddBusinessTypeToPartners < ActiveRecord::Migration[6.0]
  def change
    add_column :partners, :business_type, :integer, default: 0
  end
end
