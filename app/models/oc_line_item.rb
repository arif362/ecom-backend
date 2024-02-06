class OcLineItem < ApplicationRecord
  belongs_to :oc_product
  belongs_to :oc_purchase_order
  has_many :company_assets
end
