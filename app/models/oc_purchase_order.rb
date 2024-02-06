class OcPurchaseOrder < ApplicationRecord
  has_many :oc_line_items
  belongs_to :oc_supplier
end
