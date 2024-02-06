class Address < ApplicationRecord
  ###############
  # Associations
  ###############
  belongs_to :addressable, polymorphic: true, optional: true
  belongs_to :district
  belongs_to :thana
  belongs_to :area
  belongs_to :user, optional: true
  has_many :billing_addresses, class_name: "CustomerOrder",
           foreign_key: "billing_address_id"
  has_many :shipping_addresses, class_name: "CustomerOrder",
           foreign_key: "shipping_address_id"


  ###############
  # Validations
  ###############
  validates :district_id, :thana_id, :area_id, :address_line, presence: true
  # TODO: Need to add uniqueness title check based on user_id
  # validates :title, uniqueness: { scope: :user_id }
end
