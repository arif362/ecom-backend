class RetailerAssistant < ApplicationRecord
  audited
  # Devise
  devise :database_authenticatable,
         :registerable

  # enum
  enum status: { active: 1, inactive: 0 }
  enum category: { dedicated: 0, product_push: 1 }

  # Association
  has_one :address, as: :addressable
  belongs_to :warehouse
  has_one :app_config, as: :registrable
  has_many :coupons, as: :usable, class_name: 'Coupon'
  has_many :placed_customer_orders, as: :customer_orderable, class_name: 'CustomerOrder'
  has_many :users, as: :registerable, class_name: 'User'
  has_many :verified_users, as: :verifiable, class_name: 'User'
  belongs_to :distributor

  # validation
  validates :name, :phone, presence: true
  validates :phone, uniqueness: true
  validates :email, uniqueness: true, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates_uniqueness_of :nid, allow_blank: true
  validate :partner_retailer_phone_cannot_be_same

  def create_retailer_address(address_attributes)
    area = Area.find_by(id: address_attributes[:area_id])
    Address.create!({
                      name: name,
                      district_id: area.thana.district_id,
                      thana_id: area.thana_id,
                      area_id: area.id,
                      address_line: address_attributes[:address_line],
                      phone: phone,
                      addressable_id: id,
                      addressable_type: 'RetailerAssistant',
                   })
  end

  def partner_retailer_phone_cannot_be_same
    partner = Partner.find_by(phone: phone)
    errors.add(:phone_of, 'Partner and Retailer Assistant number can not be same') if partner
  end
end
