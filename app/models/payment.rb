class Payment < ApplicationRecord
  belongs_to :paymentable, polymorphic: true
  belongs_to :receiver, polymorphic: true, optional: true
  belongs_to :customer_order, optional: true
  belongs_to :aggregated_payment, optional: true

  validates :currency_amount, :currency_type, :status, :form_of_payment, presence: true
  validates_uniqueness_of :customer_order_id,
                          scope: %i(paymentable_type paymentable_id receiver_type receiver_id),
                          message: 'payment is already created',
                          if: lambda{ |object| object.customer_order_id.present? }

  enum status: { pending: 0, successful: 1, failed: 2, cancelled: 3, unattempted: 4, expired: 5, tempered: 6, risky: 7 }
  enum form_of_payment: { cash: 0, credit_card: 1, wallet: 2, bkash: 3, nagad: 4 }
  enum category: { customer_order: 0, partner_margin: 1, purchase_order: 2 }, _suffix: 'transaction'

  after_save :send_order_place_message, if: :successful?
  before_create :assign_category

  BKASH_TRANSACTION_STATUS = {
    "Completed": :successful,
    "Cancelled": :cancelled,
    "Declined": :failed,
    "Expired": :expired,
  }.freeze

  def self.map_bkash_to_pay_status(transactionStatus)
    case transactionStatus
    when 'Completed'
      :successful
    when 'Cancelled'
      :cancelled
    when 'Declined'
      :failed
    when 'Expired'
      :expired
    else
      :pending
    end
  end

  def send_order_place_message
    return if cash?
    return unless customer_order.status.order_placed?

    delivery_date = customer_order.express_delivery? ? customer_order.created_at + 3.hours : customer_order.created_at + 72.hours
    delivery_date = delivery_date.to_date.strftime('%d-%m-%Y')
    I18n.locale = :bn
    message = if customer_order.pick_up_point?
                I18n.t('order_place_pick_up', customer_name: customer_order.name, order_id: customer_order.backend_id,
                                              delivery_date: delivery_date, total_price: customer_order.total_price.to_i,
                                              outlet_name: customer_order&.partner&.name)
              else
                I18n.t('order_place_delivery', customer_name: customer_order.name, order_id: customer_order.backend_id,
                                              total_price: customer_order.total_price.to_i, delivery_date: delivery_date)
              end
    SmsManagement::SendMessage.call(phone: customer_order.phone, message: message)
  end

  def assign_category
    if (receiver_type == 'Partner' && paymentable_type == 'Route') || (receiver_type == 'Route' && paymentable_type == 'Staff')
      self.category = Payment.categories[:partner_margin]
    else
      self.category = Payment.categories[:customer_order]
    end
  end
end
