class Route < ApplicationRecord
  audited
  ######################################################
  ######## Model callback and custom validation ########
  ######################################################
  after_create :create_defaults
  validate :dh_changeable?

  has_one :route_device
  belongs_to :warehouse, optional: true
  belongs_to :distributor
  has_many :partners, dependent: :restrict_with_exception
  has_many :customer_orders, through: :partners
  has_many :return_customer_orders, through: :partners
  has_many :payments, as: :paymentable, dependent: :restrict_with_exception
  has_one :wallet, as: :walletable
  has_many :app_notifications, as: :notifiable
  has_one :app_config, as: :registrable
  has_many :aggregated_payments, as: :received_by, dependent: :restrict_with_exception
  validates :phone, uniqueness: true, format: { with: /\A0\d{10}\z/, message: 'Not a valid number' }, allow_blank: true
  validates :bkash_number, format: { with: /\A0\d{10}\z/, message: 'Not a valid number' }, allow_blank: true

  def customer_orders
    CustomerOrder.where(partner: partners)
  end

  def create_defaults
    create_wallet(currency_amount: 0.0, currency_type: 'Tk.')
  end

  def self.create_instance(warehouse, params)
    create!(
      warehouse: warehouse,
      title: params[:route][:title],
      bn_title: params[:route][:bn_title],
      distributor_id: params[:route][:distributor_id],
      phone: params[:route][:phone],
      sr_point: params[:route][:sr_point],
      sr_name: params[:route][:sr_name],
      created_by_id: params[:route][:created_by_id],
    )
  end

  def self.filter_with_date_time(routes, start_date_time, end_date_time)
    pay_type = CustomerOrder.pay_types[:cash_on_delivery]
    join_sql = 'LEFT JOIN partners ON routes.id=partners.route_id ' \
               'LEFT JOIN customer_orders ON partners.id = customer_orders.partner_id ' \
               'LEFT JOIN payments ON customer_orders.id=payments.customer_order_id ' \
               "AND payments.created_at BETWEEN '#{start_date_time}' AND '#{end_date_time}' " \
               "AND payments.receiver_type = 'Route'"
    select_sql = 'routes.id, routes.title, routes.sr_name, routes.sr_point, routes.bn_title, routes.phone, ' \
                 'count(customer_orders.id) as total_order, ' \
                 "count(CASE
                      WHEN customer_orders.pay_type != #{pay_type} THEN customer_orders.id
                      ELSE NULL
                   END
                  ) as prepaid_order_count, "\
                 "SUM(CASE
                      WHEN customer_orders.pay_type = #{pay_type} THEN payments.currency_amount
                      ELSE 0
                  END
                  ) as collected"
    routes.joins(join_sql).select(select_sql).group('routes.id')
  end

  def self.filter_with_date_range(customer_orders, routes, date_range)
    pay_type = CustomerOrder.pay_types[:cash_on_delivery]
    customer_orders = customer_orders.joins(:payments, :partner).where(payments: { created_at: date_range }).
      select('customer_orders.id AS id, customer_orders.pay_type AS pay_type, partners.route_id AS route_id,
      COALESCE(payments.currency_amount, 0) AS currency_amount, payments.paymentable_type AS paymentable_type,
      payments.receiver_type AS receiver_type')

    routes.joins("LEFT JOIN (#{customer_orders.to_sql}) AS customer_orders ON routes.id=customer_orders.route_id").select(
      'routes.id, routes.title, routes.sr_name, routes.sr_point, routes.bn_title, routes.phone, ' \
       "count(DISTINCT customer_orders.id) filter (where customer_orders.paymentable_type = 'Partner'
        AND customer_orders.receiver_type = 'Route') as total_order, " \
       "count(DISTINCT customer_orders.id) filter (where customer_orders.pay_type != #{pay_type} AND
       customer_orders.paymentable_type = 'Partner' AND customer_orders.receiver_type = 'Route')
       AS prepaid_order_count, "\
       "SUM(CASE
            WHEN customer_orders.paymentable_type = 'Partner' AND customer_orders.receiver_type = 'Route' THEN customer_orders.currency_amount
            ELSE 0
            END
            ) as collected_by_sr, "\
       "SUM(CASE
            WHEN customer_orders.paymentable_type = 'Route' AND customer_orders.receiver_type = 'Staff' THEN customer_orders.currency_amount
            ELSE 0
            END
            ) as collected_by_fc",
    ).group('routes.id')
  end

  def create_aggregated_SR_payment(aggregated_payment, partners, start_date, end_date)
    all_partner_margin = 0
    completed_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
    partial_return_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:partially_returned])

    partners.each do |partner|
      customer_orders = partner.customer_orders.where(status: [completed_status, partial_return_status], completed_at: start_date..end_date)
      partner_customer_orders = customer_orders.select do |order|
        order&.partner_margin&.route_received_at.blank?
      end

      partner_customer_orders.each do |order|
        margin = order.partner_margin&.margin_amount || 0
        all_partner_margin += margin
        order.aggregated_payment_customer_orders.create!(
          aggregated_payment: aggregated_payment,
          amount: margin,
          payment_type: :sr_margin,
        )
      end
    end
    all_partner_margin.round(2)
  end

  default_scope { order('id DESC') }

  def dh_changeable?
    return unless partners.present? && will_save_change_to_distributor_id?

    errors.add(:distributor_id, "can't be changed because route has assigned partners.")
  end
end
