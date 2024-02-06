class PromoCouponRule < ApplicationRecord
  belongs_to :promo_coupon
  belongs_to :ruleable, polymorphic: true

  validates_uniqueness_of :ruleable_type, scope: [:promo_coupon_id, :ruleable_id]
end
