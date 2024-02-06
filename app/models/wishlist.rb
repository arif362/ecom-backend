class Wishlist < ApplicationRecord
  belongs_to :user
  belongs_to :product

  def listed_product
    product.title
  end
end
