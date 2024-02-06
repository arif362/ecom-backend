class CouponCategory < ApplicationRecord
  belongs_to :coupon

  enum category_inclusion_type: { included: 1, excluded: 2 }
end
