class SalesRepresentative < ApplicationRecord
  has_many :partner_shops, dependent: :destroy
  belongs_to :warehouse

  validates :warehouse_id, :name, :area, presence: true
end
