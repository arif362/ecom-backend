class PurchaseOrderStatus < ApplicationRecord
  belongs_to :orderable, polymorphic: true
end
