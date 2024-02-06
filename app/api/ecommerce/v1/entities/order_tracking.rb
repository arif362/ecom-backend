# frozen_string_literal: true

module Ecommerce
  module V1
    module Entities
      class OrderTracking < Grape::Entity
        expose :order_id
        expose :created_at, as: :ordered_on
        expose :delivered_on
        expose :status
        expose :bn_status
        expose :order_type
        expose :shipping_type
        expose :total
        expose :order_track

        def order_id
          object.backend_id
        end

        def delivered_on
          case object.shipping_type
          when 'home_delivery', 'pick_up_point'
            (object.created_at + 72.hours)
          when 'express_delivery'
            (object.created_at + 3.hours)
          else
            object.created_at
          end
        end

        def order_track
          if object.pick_up_point?
            order_track_by_shipping(OrderStatus::PICKUP_ORDER_STEPS)
          else
            order_track_by_shipping(OrderStatus::HOME_DEL_ORDER_STEPS)
          end
        end

        def order_track_by_shipping(steps)
          steps = steps.map do |stat|
            status = order_status(stat)
            next if stat == 'cancelled' && status.nil?

            {
              position: fetch_status_id(status, stat),
              status: status_location_map(stat)[0],
              bn_status: bn_status_location_map(stat)[0],
              location: status_location_map(stat)[1],
              bn_location: bn_status_location_map(stat)[1],
              date_time: fetch_date_time(stat, status),
              is_complete: status.present? || stat == 'order_placed' ? true : false,
              status_key: stat,
            }
          end.compact
          steps.sort_by { |d| [d[:position], d[:is_complete]] }
        end

        def fetch_status_id(status, step)
          if step == 'order_placed'
            0
          elsif status.present?
            status.id
          else
            (2**(0.size * 8 - 2) - 1)
          end
        end

        def order_status(status)
          order_status = OrderStatus.getOrderStatus(status)
          object.customer_order_status_changes.find_by(order_status_id: order_status)
        end

        def fetch_date_time(stat, status)
          if stat == 'order_placed'
            object.created_at
          elsif status.present?
            status.created_at
          else
            ''
          end
        end

        def total
          object.total_price&.ceil
        end

        def status
          status_location_map(object.status&.order_type)[0]
        end

        def bn_status
          bn_status_location_map(object.status&.order_type)[0]
        end

        def status_location_map(status)
          case status
          when 'order_placed', 'order_confirmed'
            ['Order Placed', 'Warehouse']
          when 'ready_to_ship_from_fc', 'in_transit_to_dh', 'ready_to_shipment'
            %w(Processing Warehouse)
          when 'in_transit', 'in_transit_partner_switch', 'in_transit_delivery_switch', 'in_transit_reschedule'
            ['On the Way', 'On the Way']
          when 'completed', 'partially_returned', 'returned_from_customer'
            ['Delivered', 'To Customer']
          when 'cancelled', 'in_transit_cancelled', 'packed_cancelled', 'returned_from_partner', 'cancelled_at_in_transit_to_dh', 'cancelled_at_dh', 'cancelled_at_in_transit_to_fc'
            %w(Cancelled Warehouse)
          when 'delivered_to_partner'
            ['Delivered to Outlet', 'Partner Outlet']
          else
            ['', '']
          end
        end

        def bn_status_location_map(status)
          case status
          when 'order_placed', 'order_confirmed'
            ['অর্ডার প্লেস হয়েছে', 'ওয়্যারহাউস']
          when 'ready_to_ship_from_fc', 'in_transit_to_dh', 'ready_to_shipment'
            ['প্রসেস করা হচ্ছে', 'ওয়্যারহাউস']
          when 'in_transit', 'in_transit_partner_switch', 'in_transit_delivery_switch', 'in_transit_reschedule'
            ['যাত্রাপথে আছে', 'যাত্রাপথে আছে']
          when 'completed', 'partially_returned'
            ['ডেলিভারী করা হয়েছে', 'গ্রাহকের কাছে']
          when 'cancelled', 'in_transit_cancelled', 'packed_cancelled', 'cancelled_at_in_transit_to_dh', 'cancelled_at_dh', 'cancelled_at_in_transit_to_fc'
            ['ক্যান্সেল করা হয়েছে', 'ওয়্যারহাউস']
          when 'delivered_to_partner'
            ['দোকানে পৌঁছে গিয়েছে', 'পার্টনার আউটলেট']
          else
            ['', '']
          end
        end
      end
    end
  end
end
