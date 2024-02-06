class CustomerOrderPromotion < ApplicationRecord
  belongs_to :promotion
  belongs_to :customer_order
end
