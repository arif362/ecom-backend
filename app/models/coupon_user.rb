class CouponUser < ApplicationRecord
  belongs_to :user
  belongs_to :coupon

  validates :discount_amount, :code, presence: true

  scope :unused, -> { where(is_used: false) }
end
