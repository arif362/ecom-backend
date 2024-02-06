class District < ApplicationRecord
  audited
  has_many :thanas
  has_many :addresses
  belongs_to :warehouse, optional: true
  has_many :promo_coupon_rules, as: :ruleable, class_name: 'PromoCouponRule', dependent: :destroy
  has_many :promo_coupons, through: :promo_coupon_rules

  validates :name, :bn_name, presence: true
  validates :name, :bn_name, presence: true, uniqueness: true

  # Default scope
  default_scope { where(is_deleted: false) }
  default_scope { order(:name) }

  def self.fetch_warehouse
    joins(:warehouse).where(warehouses: { warehouse_type: %w(distribution member b2b),
                                          is_deleted: false, }).includes(:warehouse)
  end
end
