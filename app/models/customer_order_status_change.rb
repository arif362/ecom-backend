class CustomerOrderStatusChange < ApplicationRecord
  belongs_to :customer_order
  belongs_to :order_status
end
