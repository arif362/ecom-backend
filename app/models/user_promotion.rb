class UserPromotion < ApplicationRecord
  belongs_to :user
  belongs_to :customer_order, optional: true
end
