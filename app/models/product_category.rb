class ProductCategory < ApplicationRecord
  audited
  belongs_to :product
  belongs_to :category
  belongs_to :sub_category, class_name: 'Category', optional: true
end
