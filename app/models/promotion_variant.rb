class PromotionVariant < ApplicationRecord
  belongs_to :promotion
  belongs_to :variant
  # belongs_to :product, optional: true
end
