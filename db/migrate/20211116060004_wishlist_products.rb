class WishlistProducts < ActiveRecord::Migration[6.0]
  def change
    add_reference :wishlists, :product, index: true
  end
end
