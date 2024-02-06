class BrandPromotion < ApplicationRecord
  belongs_to :promotion
  belongs_to :brand
end
