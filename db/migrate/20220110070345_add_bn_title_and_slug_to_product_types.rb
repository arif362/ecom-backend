class AddBnTitleAndSlugToProductTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :product_types, :bn_title, :string
    add_column :product_types, :slug, :string
  end
end
