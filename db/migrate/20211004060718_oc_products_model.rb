class OcProductsModel < ActiveRecord::Migration[6.0]
  def up
    remove_column :oc_products, :model_name, :string
    add_column :oc_products, :model_title, :string
    change_column :oc_products, :leaf_category_id, :string, null: true
  end

  def down
    add_column :oc_products, :model_name, :string
    remove_column :oc_products, :model_title, :string
    change_column :oc_products, :leaf_category_id, :string, null: false
  end
end
