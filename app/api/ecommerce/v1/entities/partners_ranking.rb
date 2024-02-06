module Ecommerce
  module V1
    module Entities
      class PartnersRanking < Grape::Entity
        include Ecommerce::V1::Helpers::NumberHelper

        expose :ranking
        expose :outlet_name
        expose :partner_code
        expose :order_placed_num
        expose :order_completed_num
        expose :total_point
        expose :eligible_for_mega
        expose :slug

        def ranking
          object.ranking
        end

        def outlet_name
          I18n.locale == :en ? object.name : object.bn_name
        end

        def partner_code
          object.partner_code
        end

        def order_placed_num
          customer_orders = object.customer_orders.where(created_at: date_option[:start_date]..date_option[:end_date])
          customer_orders.count
        end

        def date_option
          options[:date_option]
        end

        def order_completed_num
          completed_orders_count
        end

        def total_point
          completed_orders_count * 5
        end

        def completed_orders_count
          object.customer_orders.where(order_status_id: [options[:completed], options[:partially_returned]], created_at: date_option[:start_date]..date_option[:end_date]).count
        end

        def eligible_for_mega
          completed_orders_count >= 8 ? I18n.t('Partner.ranking.yes-word') : I18n.t('Partner.ranking.no-word')
        end
      end
    end
  end
end
