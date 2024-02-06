class Area < ApplicationRecord
  has_many :addresses
  belongs_to :thana
  has_many :promo_coupon_rules, as: :ruleable, class_name: 'PromoCouponRule', dependent: :destroy
  has_many :promo_coupons, through: :promo_coupon_rules

  validates :thana_id, :name, :bn_name, presence: true
  validates :name, :bn_name, uniqueness: true

  # Default scope
  default_scope { where(is_deleted: false) }
  default_scope { order(:name) }

  scope :home_delivery_by_thana, ->(thana_id) { where(thana_id: thana_id, home_delivery: true) }
end
