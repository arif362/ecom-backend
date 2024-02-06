class AggregateReturn < ApplicationRecord
  belongs_to :customer_order
  has_many :return_customer_orders
  has_one :address, as: :addressable
  has_one :coupon
  belongs_to :warehouse
  belongs_to :distributor, optional: true
  belongs_to :rider, optional: true
  has_many :partners, through: :return_customer_orders

  def add_address(params)
    Address.create!(district_id: params[:district_id],
                    thana_id: params[:thana_id],
                    area_id: params[:area_id],
                    address_line: params[:address_line],
                    phone: params[:phone],
                    alternative_phone: params[:alternative_phone],
                    zip_code: params[:post_code],
                    addressable: self,
                    )
  end

  def update_amount(form_of_return)
    sub_total = return_customer_orders.where.not(return_status: 'cancelled').sum(&:sub_total)
    pick_up_charge = Configuration.return_pick_up_charge(form_of_return.to_s)
    vat_on_shipping = (pick_up_charge * 0.15).round
    grand_total = (sub_total - pick_up_charge - vat_on_shipping).negative? ? 0 : sub_total - pick_up_charge - vat_on_shipping
    update!(sub_total: sub_total, grand_total: grand_total, pick_up_charge: pick_up_charge,
            vat_shipping_charge: vat_on_shipping)
  end

  def frontend_id
    id.to_s.rjust(7, '0').to_s
  end
end
