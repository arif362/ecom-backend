class FilteringOption < ApplicationRecord
  belongs_to :filterable, polymorphic: true

  enum filtering_type: {
    category: 0,
    product_attribute: 1,
    price_range: 2,
    product_type: 3,
    keyword: 4,
  }
end
