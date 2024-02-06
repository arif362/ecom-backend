# frozen_string_literal: true

module Ecommerce
  module V1
    module Entities
      class ReturnOrdersList < Grape::Entity
        expose :id, as: :return_order_id
        expose :customer_order_id, as: :order_id
        expose :ordered_on
        expose :created_at, as: :requested_at
        expose :total
        expose :status
        expose :bn_status
        expose :return_method

        def ordered_on
          object.customer_order.created_at
        end

        def total
          object.shopoth_line_item.present? ? object.shopoth_line_item&.effective_unit_price : object.customer_order&.total_price
        end

        def return_method
          object.shopoth_line_item.present? ? object.form_of_return.humanize : object.customer_order&.shipping_type&.humanize
        end

        def status
          object.return_status&.humanize
        end

        def bn_status
          I18n.locale == :bn ? I18n.t("return_order_status.#{object.return_status}") : ''
        end
      end
    end
  end
end
