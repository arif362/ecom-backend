class User < ApplicationRecord
  after_create :create_defaults
  before_create :generate_otp
  before_save :validate_status, if: :will_save_change_to_status?
  before_save :validate_deletion, if: :will_save_change_to_is_deleted?
  after_save :send_first_reg_coupon_sms, if: :saved_change_to_is_otp_verified?
  ###############
  # Device Modules
  ###############
  devise :registerable,
         :recoverable,
         :database_authenticatable,
         :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtBlacklist

  ###############
  # Validations
  ###############
  VALID_PHONE_NUMBER_REGEX = /\d\z/
  validates :password, :password_confirmation, presence: true, on: :create
  validates :phone, presence: true, format: { with: /\d\z/, message: 'Not a valid phone number' }
  validates :email, uniqueness: true, format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/ }, allow_blank: true, if: :email?
  validates_length_of :phone, minimum: 11, maximum: 11
  validates :age, numericality: { greater_than: 0, less_than_or_equal_to: 150 }, if: :age
  validates :full_name, presence: true, format: { with: /\A[a-zA-Z0-9.\s]+\Z/ }
  validates :image, blob: { content_type: %w(image/jpg image/jpeg image/png), size_range: 1..5.megabytes }, on: :save
  validate :check_unique_phone
  validates :whatsapp, :viber, :imo, uniqueness: {scope: :is_deleted}, length: {minimum: 6}, format: { with: VALID_PHONE_NUMBER_REGEX }, allow_blank: true, unless: :is_deleted
  validates :nid, uniqueness: {scope: :is_deleted}, length: {minimum: 10, maximum: 17}, format: { with: /\d\z/ }, allow_blank: true, unless: :is_deleted
  validates :home_address, length: {minimum: 15}, allow_blank: true

  ###############
  # Association
  ###############
  has_one_attached :image
  has_one :user_preference
  has_many :wishlists, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :customer_orders, as: :customer
  has_many :shopoth_line_items, through: :customer_orders
  has_many :payments, as: :paymentable
  has_many :addresses, as: :addressable
  has_many :notifications, dependent: :destroy
  has_one :wallet, as: :walletable
  has_many :delivery_preferences, dependent: :destroy
  has_one :cart, dependent: :destroy
  has_one :user_promotion, dependent: :destroy
  has_many :return_customer_orders, through: :customer_orders
  has_many :authorization_keys, as: :authable, class_name: 'AuthorizationKey'
  has_many :placed_customer_orders, as: :customer_orderable, class_name: 'CustomerOrder'
  has_many :coupons, as: :usable, class_name: 'Coupon'
  has_many :placed_return_orders, as: :return_orderable, class_name: 'ReturnCustomerOrder'
  belongs_to :registerable, polymorphic: true, optional: true
  belongs_to :verifiable, polymorphic: true, optional: true
  belongs_to :partner, optional: true
  has_many :requested_variants, dependent: :destroy
  has_many :favorite_stores, dependent: :destroy
  has_many :brand_followings
  has_many :feedbacks
  has_many :aggregate_returns, -> { distinct }, through: :return_customer_orders
  has_many :searches
  has_many :customer_device_users
  has_many :customer_devices, through: :customer_device_users
  has_many :promo_coupon_rules, as: :ruleable, class_name: 'PromoCouponRule', dependent: :destroy
  has_many :promo_coupons, through: :promo_coupon_rules
  has_many :user_modification_requests, -> { where(status: :pending) }, dependent: :delete_all
  has_many :coupon_users, dependent: :restrict_with_error
  has_one :ambassador
  has_many :users, as: :registerable, class_name: 'User'
  has_many :customer_acquisitions, as: :registered_by
  has_one :customer_acquisition
  has_many :app_notifications, as: :notifiable
  has_one :app_config, as: :registrable

  has_many :third_party_logs, as: :user_able


  def self.with_retailer_assistant
    joins("
      LEFT OUTER JOIN retailer_assistants ON retailer_assistants.id = users.registerable_id AND users.registerable_type = 'RetailerAssistant'
    ").joins('LEFT OUTER JOIN partners ON partners.id = users.partner_id').select('users.*, retailer_assistants.phone as ra_phone, partners.partner_code as partner_code')
  end

  ###############
  # Enumerable
  ###############
  enum status: { active: 0, inactive: 1 }
  enum gender: { female: 0, male: 1, others: 2 }
  enum user_type: { shopoth: 0, member: 1 }
  enum category: { general: 0, cs_agent: 1, field_force: 2 }

  ###############
  # Scope
  ###############
  default_scope { where(is_deleted: false) }

  def image_file=(file)
    image&.attach(
      io: file[:tempfile],
      filename: file[:filename],
      content_type: file[:type],
    )
  end

  def email_required?
    false
  end

  def self.find_by_email_or_phone(email_or_phone)
    find_by('? IN (email, phone)', email_or_phone)
  end

  def to_s
    name
  end

  def name
    full_name
  end

  def add_address(params)
    Address.create!(district_id: params[:district_id],
                    thana_id: params[:thana_id],
                    area_id: params[:area_id],
                    address_line: params[:address_line],
                    phone: params[:phone],
                    alternative_phone: params[:alternative_phone],
                    zip_code: params[:post_code],
                    addressable: self,
                    default_address: true)
  end

  def self.find_user_by_phone(phone)
    find_by(phone: phone)
  end

  def self.valid_user?(email_or_phone, password, domain)
    user = User.find_by_email_or_phone(email_or_phone)
    return { success: false, error: I18n.t('Ecom.errors.messages.invalid_phone_or_email') } unless user
    unless user.valid_password?(password)
      return { success: false, error: I18n.t('Ecom.errors.messages.password_mismatch') }
    end
    unless user.is_otp_verified
      return { success: false, error: I18n.t('Ecom.errors.messages.otp_varification_not_done') }
    end
    if user.shopoth? && domain == "#{ENV['MEMBER_WAREHOUSE']}"
      return { success: false, error: I18n.t('Ecom.errors.messages.member_auth_error') }
    end

    { success: true, error: '', user: user }
  end

  def create_defaults
    create_wallet(currency_amount: 0.0, currency_type: 'Tk.')
  end

  def change_otp
    rand(10_000..99_999)
  end

  def self.remote_uniqueness_and_validation_check(content, field_name)
    content = content.gsub(/\s|-/, "")
    user = eval("User.find_by(#{field_name}: '#{content}', is_otp_verified: true, status: :active, is_deleted: [false, nil])")
    return false if user.present?
    if field_name == 'nid'
      return false unless content.length >= 7 and content.length <= 17 and content.match?(/\d\z/)
    else
      return false unless content.match?(VALID_PHONE_NUMBER_REGEX) and content.length >= 6
    end
    true
  end

  def update_as_ambassador!(params, locale = 'en')
    I18n.locale = locale
    fail StandardError, I18n.t('common.errors.messages.min_1_social_required') if params[:whatsapp].blank? and params[:viber].blank? and params[:imo].blank?
    social_params = {}
    social_params[:whatsapp] = params[:whatsapp] if params[:whatsapp].present?
    social_params[:viber] = params[:viber] if params[:viber].present?
    social_params[:imo] = params[:imo] if params[:imo].present?
    ActiveRecord::Base.transaction do
      create_ambassador!(bkash_number: params[:bkash_number], preferred_name: params[:preferred_name])
      update!(social_params)
    end
  end

  private
  def validate_status
    case status_in_database
    when 'active'
      fail "User is already active" if active?
      fail 'active orders exist' if count_active_order > 0
      unless coupons.where.not(aggregate_return_id: nil).where(is_used: false).count.zero?
        fail 'return coupon exist'
      end
    when 'inactive'
      fail "User is already inactive" if inactive?
    end
  end

  def validate_deletion
    fail 'active orders exist' if is_deleted && count_active_order > 0
    unless coupons.where.not(aggregate_return_id: nil).where(is_used: false).count.zero?
      fail 'return coupon exist'
    end
  end

  def count_active_order
    active_statuses = %w[order_placed order_confirmed ready_to_shipment in_transit in_transit_partner_switch
        in_transit_delivery_switch delivered_to_partner on_hold in_transit_reschedule ready_to_ship_from_fc in_transit_to_dh]
    order_types = OrderStatus.order_types
    active_order_type_values = active_statuses.map{|as| order_types[as]}
    customer_orders.joins(:status).where("order_statuses.order_type in (?) ", active_order_type_values).count
  end

  def generate_otp
    self.otp = rand(10_000..99_999)
  end

  def check_unique_phone
    return true if saved_change_to_phone?

    if User.where.not(id: id).find_by(phone: phone, is_deleted: false).present?
      errors.add(:base, 'Phone has already been taken')
    end
  end

  def send_first_reg_coupon_sms
    return true if is_otp_verified == false

    first_time_coupon = Coupon.first_registration.active.last
    return unless first_time_coupon.present? && first_time_coupon.running?

    CouponSmsJob.perform_later(first_time_coupon, phone)
  end
end
