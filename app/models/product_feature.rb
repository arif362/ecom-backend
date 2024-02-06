class ProductFeature < ApplicationRecord
  audited
  belongs_to :product, optional: true
  default_scope { order(id: :asc) }
end
