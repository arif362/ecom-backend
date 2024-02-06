class ProductType < ApplicationRecord
  include Sluggable
  audited
  has_many :products_product_types, dependent: :destroy
  has_many :products, through: :products_product_types
  has_one :meta_datum, as: :metable, class_name: 'MetaDatum'

  validates_uniqueness_of :title, :bn_title

  accepts_nested_attributes_for :meta_datum, reject_if: :all_blank, allow_destroy: true
end
