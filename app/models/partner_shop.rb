class PartnerShop < ApplicationRecord
  # has_one :address
  belongs_to :sales_representative

  validates :sales_representative_id, :day, presence: true
end
