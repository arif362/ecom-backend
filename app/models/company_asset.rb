class CompanyAsset < ApplicationRecord
  belongs_to :oc_line_item
  belongs_to :oc_product
  belongs_to :asset_location

  validates :tag, uniqueness: true
end
