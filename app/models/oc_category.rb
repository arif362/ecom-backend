class OcCategory < ApplicationRecord
  belongs_to :parent, class_name: 'OcCategory', optional: true
  has_many :sub_categories, class_name: 'OcCategory', foreign_key: :parent_id, dependent: :destroy
  has_many :oc_products
end
