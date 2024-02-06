class AssetTagUnique < ActiveRecord::Migration[6.0]
  def change
    add_index :company_assets, :tag, unique: true
  end
end
