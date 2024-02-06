class ReplaceProductReferenceWithVariant < ActiveRecord::Migration[6.0]
  def change
    remove_reference :wishlists, :product
    add_reference :wishlists, :variant, index: true, foreign_key: true
  end
end
