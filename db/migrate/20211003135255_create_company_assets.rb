class CreateCompanyAssets < ActiveRecord::Migration[6.0]
  def change
    create_table :company_assets do |t|
      t.references :oc_line_item, null: false, foreign_key: true, index: true
      t.references :asset_location, foreign_key: true
      t.references :oc_product, foreign_key: true
      t.string :tag
      t.string :details
      t.timestamps
    end
  end
end
