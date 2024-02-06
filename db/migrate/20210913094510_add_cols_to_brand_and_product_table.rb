class AddColsToBrandAndProductTable < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :brand_id, :integer unless column_exists? :products, :brand_id
    add_column :brands, :bn_name, :string, default: '' unless column_exists? :brands, :bn_name
    add_column :brands, :is_deleted, :boolean, default: false unless column_exists? :brands, :is_deleted
  end
end
