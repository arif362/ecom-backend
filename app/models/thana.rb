class Thana < ApplicationRecord
  has_many :areas
  has_many :addresses
  belongs_to :district
  belongs_to :distributor
  has_many :promo_coupon_rules, as: :ruleable, class_name: 'PromoCouponRule', dependent: :destroy
  has_many :promo_coupons, through: :promo_coupon_rules

  validates :district_id, :distributor_id, :name, :bn_name, presence: true
  validates_uniqueness_of :name, scope: :district_id, message: 'is already created under this district.'

  # Default scope
  default_scope { where(is_deleted: false) }
  default_scope { order(:name) }

  scope :home_delivery_by_district, ->(district_id) { where(district_id: district_id, home_delivery: true) }
end
