class StaffRole < ApplicationRecord
  has_many :staffs
  validates :name, uniqueness: true

  ROLE_NAMES = {
    shopoth_admin: 'Shopoth Admin',
    distribution_house_manager: 'Distribution House Manager',
    normal_admin: 'Normal Admin',
    product_manager: 'Product Manager',
    supplier_manager: 'Supplier Manager',
    call_center_staff: 'Call Center Staff',
    sr: 'SR',
  }.freeze
end
