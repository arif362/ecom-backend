class Invoice < ApplicationRecord
  belongs_to :customer_order
end
