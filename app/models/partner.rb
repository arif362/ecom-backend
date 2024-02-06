class Partner < ApplicationRecord
  include Rails.application.routes.url_helpers
  include Sluggable
  audited
  serialize :work_days, Array

  belongs_to :route
  has_many :customer_orders
  has_many :return_customer_orders
  has_many :payments, as: :paymentable
  has_one :wallet, as: :walletable
  has_many :app_notifications, as: :notifiable
  has_many :customer_care_reports, as: :reporter
  has_one :app_config, as: :registrable
  has_many :carts, dependent: :destroy
  # has_one :authorization_key, as: :authable, class_name: 'AuthorizationKey'
  has_many :placed_customer_orders, as: :customer_orderable, class_name: 'CustomerOrder'
  has_many :partner_margins, dependent: :restrict_with_exception
  has_many :placed_return_orders, as: :return_orderable, class_name: 'ReturnCustomerOrder'
  has_many :users, as: :registerable, class_name: 'User'
  has_many :aggregated_payments, as: :received_by
  has_many :reviews, as: :reviewable, dependent: :destroy
  has_many :favorite_stores, dependent: :destroy
  has_one :meta_datum, as: :metable, class_name: 'MetaDatum'
  has_many :promo_coupon_rules, as: :ruleable, class_name: 'PromoCouponRule', dependent: :destroy
  has_many :promo_coupons, through: :promo_coupon_rules
  has_many :customer_acquisitions, as: :registered_by

  enum status: {
    active: 0,
    inactive: 1,
  }
  devise :database_authenticatable
  has_one_attached :image
  has_one :address, as: :addressable
  has_many :delivery_preferences
  validates :phone, :partner_code, uniqueness: true
  validates :name, :route_id, presence: true
  validates :password, :password_confirmation, presence: true, on: :create
  validates :password_confirmation, presence: true, on: :update, unless: -> { password.blank? }
  validates :image, blob: { content_type: %w(image/jpg image/jpeg image/png image/webp), size_range: 1..5.megabytes }
  validates :bkash_number, format: { with: /\A0\d{10}\z/, message: 'Not a valid number' }, allow_blank: true

  accepts_nested_attributes_for :address, reject_if: :all_blank, allow_destroy: true, update_only: true
  accepts_nested_attributes_for :meta_datum, reject_if: :all_blank, allow_destroy: true

  enum schedule: { sat_mon_wed: 0, sun_tues_thurs: 1, sat_sun_mon_tues_wed_thurs: 2 }
  enum business_type: { b2c: 0, b2b: 1, both: 2 }

  default_scope { order('id DESC') }

  attr_accessor :ranking

  ######################################################
  ######## Model callback and custom validation ########
  ######################################################
  after_create :create_defaults
  before_update :remove_favorite_store_list_if_updated_as_inactive
  validate :route_changeable?
  # TODO: Need to convert partner_address_check after_save model callback into custom validation method.
  # after_save :partner_address_check

  def image_file=(file)
    return if file.blank?

    image&.attach(
      io: file[:tempfile],
      filename: file[:filename],
      content_type: file[:type],
    )
  end

  def customer_acquisition_reports(params = {})
    acquisition_data = customer_acquisitions.
      where(created_at: start_date(params)..end_date(params)).
      where.not(information_status: :incomplete)
    results = acquisition_data.
      group(:information_status).
      pluck('information_status', 'count(id)', 'sum(amount)')


    stat = {
      total_registrations: 0,
      total_amounts: 0,
      amount_received: acquisition_data.where(is_paid: true).sum(:amount).to_d.round,
      half: {registrations: 0, amounts: 0},
      full: {registrations: 0, amounts: 0},
    }
    results.each do |arr|
      stat[:total_registrations] += arr[1]
      stat[:total_amounts] += arr[2]
      temp = {
        registrations: arr[1],
        amounts: arr[2],
      }
      arr[0] == 'half' ? stat[:half] = temp : stat[:full] = temp
    end
    stat[:total_registrations] = stat[:total_registrations]
    stat[:total_amounts] = stat[:total_amounts].to_d.round
    stat[:half][:amounts] = stat[:half][:amounts].to_d.round
    stat[:full][:amounts] = stat[:full][:amounts].to_d.round
    stat
  end

  def self.find_by_area(area_id)
    where(status: 'active').joins(:address).where('addresses.area_id = ?', area_id)
  end

  def create_defaults
    create_wallet(currency_amount: 0.0, currency_type: 'Tk.')
  end

  def self.sizes
    {
      small: { resize: '100x100' },
    }
  end

  def self.filter_by_address(district_id, thana_id, area_id, address_line)
    partners = all
    partners = partners.joins(:address).where(addresses: { district_id: district_id }) if district_id.present?
    partners = partners.joins(:address).where(addresses: { thana_id: thana_id }) if thana_id.present?
    partners = partners.joins(:address).where(addresses: { area_id: area_id}) if area_id.present?
    partners = partners.joins(:address).where(['LOWER(addresses.address_line) LIKE ?', "%#{address_line.downcase}%"]) if address_line.present?
    partners.order(created_at: :desc)
  end

  def self.fetch_route_partners(statuses, route)
    Partner.find_by_sql("
                      SELECT DISTINCT p.*, COALESCE(SUM(co.total_price),0) AS due_payment FROM partners p
                      LEFT JOIN customer_orders co ON co.partner_id = p.id AND co.pay_status NOT IN(2, 5)
                      AND co.order_status_id IN(#{statuses})
                      AND co.pay_type = #{CustomerOrder.pay_types[:cash_on_delivery]}
                      WHERE p.route_id = #{route.id}
                      GROUP BY p.id
                      ORDER BY p.created_at DESC
                    ")
  end

  def create_aggregated_partner_payment(aggregated_payment, customer_orders)
    total_partner_margin = 0

    partner_customer_orders = customer_orders.select do |order|
      order&.partner_margin&.partner_received_at.blank?
    end

    partner_customer_orders.each do |order|
      margin = order.partner_margin&.margin_amount || 0
      total_partner_margin += margin
      order.aggregated_payment_customer_orders.create!(
        aggregated_payment: aggregated_payment,
        amount: margin,
        payment_type: :partner_margin,
      )

      order.partner_margin.update!(partner_received_at: Time.now, partner_received_amount: margin)
    end

    total_partner_margin
  end

  def location_difference(user_latitude, user_longitude)
    Geocoder::Calculations.distance_between([latitude.to_d, longitude.to_d], [user_latitude, user_longitude])
  end

  def remove_favorite_store_list_if_updated_as_inactive
    if status_changed? && status == 'inactive'
      PartnerRemoveFromFavouriteToAllJob.perform_later(id)
    end
  end

  def route_changeable?
    return unless customer_orders.present? && will_save_change_to_route_id?

    errors.add(:route_id, "can't be changed because partner has customer orders.")
  end

  def partner_address_check
    return if route.distributor.thanas.find_by(id: address.thana_id)

    Rails.logger.error "\n\n#{__LINE__}\n Thana isn't in the distributor territory."
    errors.add(:base, "Thana isn't in the distributor territory.")
    fail ActiveRecord::Rollback, "Thana isn't in the distributor territory."
  end

  private
  def start_date(params={})
    month = params[:month]
    year = params[:year]
    start_date = if month.present? && year.present?
                   DateTime.civil(year, month, 1).in_time_zone('Dhaka')
                 else
                   DateTime.now.beginning_of_month
                 end
    start_date.beginning_of_day
  end

  def end_date(params={})
    month = params[:month]
    year = params[:year]
    end_date = if month.present? && year.present?
                 DateTime.civil(year, month, -1).in_time_zone('Dhaka')
               else
                 DateTime.now.end_of_month
               end
    end_date.end_of_day
  end
end
