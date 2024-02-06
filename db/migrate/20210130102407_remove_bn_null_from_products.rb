class RemoveBnNullFromProducts < ActiveRecord::Migration[6.0]
  def change
    change_column :products, :bn_title, :string, :null => true
    change_column :products, :bn_company, :string, :null => true
    change_column :products, :bn_brand, :string, :null => true
  end
end
