class Rider < ApplicationRecord
  include BCrypt
  audited
  ######################################################
  ######## Model callback and custom validation ########
  ######################################################
  after_create :create_defaults
  validate :dh_changeable?

  belongs_to :warehouse
  belongs_to :distributor, optional: true
  has_many :payments, as: :paymentable
  has_one :wallet, as: :walletable
  has_many :app_notifications, as: :notifiable
  has_many :customer_care_reports, as: :reporter
  has_many :customer_orders
  has_one :app_config, as: :registrable
  has_many :aggregate_returns
  has_many :return_customer_orders, through: :aggregate_returns
  has_one :authorization_key, as: :authable, class_name: 'AuthorizationKey'

  # validation
  validates :phone, presence: true, uniqueness: true
  validates :email, uniqueness: true, allow_blank: true

  def create_defaults
    create_wallet(currency_amount: 0.0, currency_type: 'Tk.')
  end

  default_scope { order('id DESC') }

  def self.filter_with_date_time(riders, status, start_date_time, end_date_time)
    pay_type = CustomerOrder.pay_types[:cash_on_delivery]
    join_sql = 'LEFT JOIN customer_orders ON riders.id = customer_orders.rider_id ' \
               'LEFT JOIN customer_order_status_changes ON customer_orders.id = customer_order_status_changes.customer_order_id ' \
               "AND customer_order_status_changes.order_status_id=#{status.id} " \
               'LEFT JOIN payments ON customer_orders.id=payments.customer_order_id ' \
               "AND payments.created_at BETWEEN '#{start_date_time}' AND '#{end_date_time}' " \
               "AND payments.receiver_type = 'Rider'"
    select_sql = 'riders.id, riders.name, riders.phone, riders.email, riders.warehouse_id, ' \
                 'count(customer_orders.id) as total_order, ' \
                 "count(CASE
                      WHEN customer_orders.pay_type != #{pay_type} THEN customer_orders.id
                      ELSE NULL
                   END
                  ) as online_order, "\
                 "SUM(CASE
                      WHEN customer_orders.pay_type = #{pay_type} THEN payments.currency_amount
                      ELSE 0
                  END
                  ) as cash_collected, " \
                 "sum(CASE
                        WHEN customer_orders.pay_type = #{pay_type} THEN customer_orders.total_price
                        ELSE 0
                  END
                  ) as total_amount"
    riders.joins(join_sql).select(select_sql).group('riders.id')
  end

  def self.filter_with_date_range(customer_orders, riders, start_date_time, end_date_time)
    pay_type = CustomerOrder.pay_types[:cash_on_delivery]
    customer_orders = customer_orders.joins(:payments)
                                    .where('payments.created_at >= ? AND payments.created_at <= ? AND payments.receiver_type = ?', start_date_time, end_date_time, 'Rider')
                                    .select('customer_orders.id AS id, customer_orders.pay_type AS pay_type, customer_orders.rider_id AS rider_id, COALESCE(payments.currency_amount, 0) AS amount')

    riders.joins("LEFT JOIN (#{customer_orders.to_sql}) AS customer_orders ON riders.id=customer_orders.rider_id").select(
      'riders.id, riders.name, riders.phone, riders.email, riders.warehouse_id, riders.distributor_id, ' \
                 'count(DISTINCT customer_orders.id) as total_order, ' \
                 "count(DISTINCT customer_orders.id) filter (where customer_orders.pay_type != #{pay_type})
                 AS prepaid_order_count, "\
                 'COALESCE(SUM(customer_orders.amount), 0) AS collected',
    ).group('riders.id')
  end

  def dh_changeable?
    return unless customer_orders.present? && will_save_change_to_distributor_id?

    errors.add(:distributor_id, "can't be changed because rider has customer orders.")
  end

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
end
