class CartPromotion < ApplicationRecord
  belongs_to :cart
  belongs_to :promotion
end
