class BankTransaction < ApplicationRecord
  audited
  belongs_to :debit_bank_account, class_name: 'BankAccount', optional: true
  belongs_to :credit_bank_account, class_name: 'BankAccount'
  belongs_to :transactionable_for, polymorphic: true
  belongs_to :transactionable_by, polymorphic: true
  belongs_to :transactionable_to, polymorphic: true

  has_many_attached :images

  def images_file=(file_arr)
    return if file_arr.blank?

    img_arr = []
    file_arr.each do |file|
      file_hash = {
        io: file[:tempfile],
        filename: file[:filename],
        content_type: file[:type],
      }
      img_arr << file_hash
    end
    self.images = img_arr
  end

  def self.get_img_url(image_variation, obj)
    Rails.application.routes.url_helpers.rails_representation_url(obj.variant(Product.sizes[image_variation.to_sym]).processed, only_path: true)
  end

  def self.create_aggregated_transaction_customer_orders(customer_orders, transaction)
    total_amount = 0
    customer_orders.each do |customer_order|
      next unless customer_order.aggregated_transaction_customer_orders.customer_payment.blank?

      order_price = customer_order.payments.where(paymentable_type: %w(Route Rider), receiver_type: 'Staff').sum(:currency_amount)
      customer_order.aggregated_transaction_customer_orders.create!(
        aggregated_transaction_id: transaction.id,
        amount: order_price,
        transaction_type: :customer_payment,
      )
      total_amount += order_price
    end
    total_amount.ceil
  end

  def self.create_aggregated_agent_commission(distributor, date_range, transaction, statuses, staff)
    total_amount = 0
    customer_orders = distributor.customer_orders.where(status: statuses, completed_at: date_range)
    customer_orders.each do |order|
      next if order.aggregated_transaction_customer_orders&.agent_commission.present?

      dh_commission = order.distributor_margin&.amount || 0
      order.aggregated_transaction_customer_orders.create!(
        aggregated_transaction: transaction,
        transaction_type: :agent_commission,
        amount: dh_commission,
      )
      order.distributor_margin.update!(payable_type: staff.class.to_s, payable_id: staff.id, paid_at: Time.now)
      total_amount += dh_commission
    end
    { total_amount: total_amount, partners_margin: total_amount.round(2) }
  end

  def self.create_aggregated_sub_agent_commission(distributor, date_range, transaction, statuses)
    customer_orders = distributor.customer_orders.pick_up_point.where(
      status: statuses, completed_at: date_range, partner_id: distributor.partners.ids,
    )

    total_amount = 0
    partners_margin = 0
    customer_orders.group_by(&:partner_id).each do |partner_id, orders|
      orders.each do |order|
        next if order.aggregated_transaction_customer_orders&.sub_agent_commission.present?

        partner_margin = 0
        if order.induced? || (order.organic? && order.pick_up_point?)
          partner_margin = order.partner_margin&.margin_amount
        end

        order.aggregated_transaction_customer_orders.create!(
          aggregated_transaction: transaction,
          amount: partner_margin,
          transaction_type: :sub_agent_commission,
        )
        total_amount += partner_margin
        partners_margin += partner_margin
      end
      partners_margin = partners_margin.round(2)
    end
    { total_amount: total_amount, partners_margin: partners_margin }
  end
end
