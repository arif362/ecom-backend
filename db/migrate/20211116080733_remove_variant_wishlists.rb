class RemoveVariantWishlists < ActiveRecord::Migration[6.0]
  def change
    remove_index :wishlists, :variant_id
    remove_column :wishlists, :variant_id
    add_foreign_key :wishlists, :products
  end
end
