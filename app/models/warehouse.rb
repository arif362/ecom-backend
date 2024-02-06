class Warehouse < ApplicationRecord
  devise :registerable,
         :database_authenticatable,
         :validatable

  has_one :address, as: :addressable, dependent: :destroy
  has_many :districts
  has_many :storages
  has_many :warehouse_storages
  has_many :sales_representatives
  has_many :dh_purchase_orders
  has_many :staffs, dependent: :destroy
  has_many :warehouse_variants
  has_many :return_customer_orders
  has_many :variants, through: :warehouse_variants
  has_many :products, through: :variants
  has_many :customer_orders
  has_many :routes
  has_many :partners, through: :routes
  has_many :warehouse_collect_histories
  has_many :riders
  has_one :wallet, as: :walletable
  has_many :locations
  has_many :coupons
  has_many :failed_qcs
  has_many :retailer_assistants, dependent: :destroy
  has_many :promotions, dependent: :destroy
  has_many :payments, as: :paymentable
  has_many :blocked_items
  has_many :stock_changes
  has_many :bank_accounts, as: :ownerable, dependent: :restrict_with_exception
  has_many :bank_transaction_payments, as: :transactionable_by, dependent: :restrict_with_exception
  has_many :bank_transaction_receives, as: :transactionable_to, dependent: :restrict_with_exception
  has_many :aggregate_returns
  has_many :requested_variants, dependent: :destroy
  has_many :searches
  has_many :warehouse_margins, dependent: :restrict_with_exception
  has_many :month_wise_payment_histories, dependent: :restrict_with_exception
  has_many :distributors, dependent: :restrict_with_exception
  has_many :return_transfer_orders
  has_many :promo_coupon_rules, as: :ruleable, class_name: 'PromoCouponRule', dependent: :destroy
  has_many :promo_coupons, through: :promo_coupon_rules
  has_many :warehouse_bundles
  has_many :challans, dependent: :restrict_with_exception
  has_many :return_challans, dependent: :restrict_with_exception

  WAREHOUSE_TYPES = { central: 'central', distribution: 'distribution', member: 'member', b2b: 'b2b' }.freeze
  SUB_DOMAIN = 'dhk'.freeze

  validates :name, presence: true
  validates :email, :name, :bn_name, uniqueness: { scope: :is_deleted }
  validates :password, :password_confirmation, presence: true, on: :create
  validates :password_confirmation, presence: true, on: :update, unless: -> { password.blank? }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  # validate :bn_name_validation
  validates :warehouse_type, inclusion: { in: WAREHOUSE_TYPES.map { |_key, val| val },
                                          message: 'is not a valid warehouse_type', }

  after_create :create_staff

  default_scope { where(is_deleted: false) }
  default_scope { order('id DESC') }

  enum status: { active: 0, inactive: 1 }

  def self.distribution_house
    where(warehouse_type: [WAREHOUSE_TYPES[:distribution], WAREHOUSE_TYPES[:member], WAREHOUSE_TYPES[:b2b]])
  end

  def bn_name_validation
    if bn_name.blank? && WarehouseConfiguration::LOCALE == 'bn'
      errors.add(:base, 'Bengali name cannot be blank')
      false
    else
      true
    end
  end

  def self.find_by_district_id(district_id)
    Address.where(district_id: district_id, addressable_type: 'Warehouse')&.first.addressable
  end

  def create_staff
    role_name = if warehouse_type == WAREHOUSE_TYPES[:central]
                  StaffRole::ROLE_NAMES[:shopoth_admin]
                else
                  StaffRole::ROLE_NAMES[:distribution_house_manager]
                end
    staff_role = StaffRole.find_or_create_by(name: role_name)
    errors.add(:base, 'Staff role must be present for creating a staff under this Fc') if staff_role.blank?

    staff_role.staffs.create!(
      first_name: name,
      last_name: role_name,
      email: email,
      password: password,
      password_confirmation: password_confirmation,
      warehouse_id: id,
      staff_role_id: staff_role.id,
      staffable: self,
    )
    puts "--- Shopoth admin staff created for #{warehouse_type}, id: #{id}, name: #{name}"
  rescue StandardError => error
    puts "--- Error creating main staff while creating warehouse due to: #{error}"
    raise ActiveRecord::Rollback
  end

  def soft_delete
    update!({ is_deleted: true })
  end
end
