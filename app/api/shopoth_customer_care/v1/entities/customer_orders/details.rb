module ShopothCustomerCare
  module V1
    module Entities
      module CustomerOrders
        class Details < Grape::Entity
          expose :id, as: :order_id
          expose :backend_id, as: :order_no
          expose :status
          expose :status_key
          expose :cancellation_reason
          expose :created_at, as: :order_at
          expose :preferred_delivery_date
          expose :customer
          expose :shipping_type
          expose :shipping_type_id
          expose :partner
          expose :pay_type
          expose :warehouse
          expose :route
          expose :rider
          expose :ShippingAddress
          expose :BillingAddress
          expose :order_type
          expose :shopoth_line_items_total_price, as: :sub_total
          expose :shipping_charge
          expose :vat_shipping_charge
          expose :total_discount_amount
          expose :total_price, as: :grand_total
          expose :shopoth_line_items, using: ShopothCustomerCare::V1::Entities::ShopothLineItemList
          expose :returned_order_items
          expose :order_tracking
          expose :is_customer_paid
          expose :receiver_info
          expose :is_returnable
          expose :cancellable
          expose :distributor_id
          expose :distributor_name
          expose :business_type

          def order_tracking
            object.customer_order_status_changes&.map do |order_status_change|
              {
                status: order_status_change&.order_status&.customer_order_status,
                time: order_status_change.updated_at,
              }
            end
          end

          def status_key
            object.status&.order_type
          end

          def returned_order_items
            object.return_customer_orders&.map do |return_order|
              {
                return_order_id: return_order.return_type == 'unpacked' ? return_order.aggregate_return_id : return_order.id,
                return_type: return_order.return_type,
                return_request_date: return_order.created_at,
                price: return_order.shopoth_line_item&.effective_unit_price,
                return_status: return_order.return_status,
                # item: return_order.shopoth_line_item&.variant&.product&.title,
                item: item(return_order.shopoth_line_item),
              }
            end
          end

          def item(shopoth_line_item)
            if shopoth_line_item.present?
              variant = shopoth_line_item.variant
              {
                product_title: variant&.product&.title,
                sku: variant&.sku,
                product_attribute_values: product_attribute_values(variant),
              }
            else
              {}
            end
          end

          def product_attribute_values(variant)
            if variant.present? && variant.product_attribute_values.present?
              variant.product_attribute_values.map do |attribute_value|
                {
                  id: attribute_value.id,
                  product_attribute_id: attribute_value.product_attribute_id,
                  name: attribute_value.product_attribute&.name,
                  value: attribute_value.value,
                  bn_name: attribute_value.product_attribute&.bn_name,
                  bn_value: attribute_value.bn_value,
                  created_at: attribute_value.created_at,
                  updated_at: attribute_value.updated_at,
                  is_deleted: attribute_value.is_deleted,
                }
              end
            end
          end

          def partner
            partner = object&.partner
            if partner.present?
              {
                id: partner.id,
                name: partner.name,
                phone: partner.phone,
                email: partner.email,
                route_id: partner.route_id,
                area_name: address&.area&.name,
                area_id: address&.area&.id,
                thana_id: address&.thana&.id,
                thana: address&.thana&.name,
                district_id: address&.district&.id,
                district: address&.district&.name,
                section: section,
              }
            else
              {}
            end
          end

          def warehouse
            warehouse = object&.warehouse
            if warehouse.present?
              {
                name: warehouse.name,
                phone: warehouse.phone,
                email: warehouse.email,
                route_id: warehouse.warehouse_type,
              }
            else
              {}
            end
          end

          def route
            route = object&.partner&.route
            if route.present?
              {
                title: route.title,
                phone: route.phone,
              }
            else
              {}
            end
          end

          def rider
            rider = object&.rider
            if rider.present?
              {
                name: rider.name,
                phone: rider.phone,
                email: rider.email,
              }
            else
              {}
            end
          end

          def ShippingAddress
            shipping_address = object&.shipping_address
            if shipping_address.present?
              {
                area_id: shipping_address.area.id,
                area: shipping_address.area.name,
                thana_id: shipping_address.thana.id,
                thana: shipping_address.thana.name,
                district_id: shipping_address.district.id,
                district: shipping_address.district.name,
                phone: shipping_address.phone,
                address_line: shipping_address.address_line,
              }
            else
              {}
            end
          end

          def BillingAddress
            billing_address = object&.billing_address
            if billing_address.present?
              {
                area: billing_address.area.name,
                thana: billing_address.thana.name,
                district: billing_address.district.name,
                phone: billing_address.phone,
                address_line: billing_address.address_line,
              }
            else
              {}
            end
          end

          def customer
            customer = object.b2b? ? Partner.unscoped.find_by(id: object.customer_id) : User.unscoped.find_by(id: object.customer_id)
            if customer.present?
              {
                id: customer.id,
                customer_type: object.customer_type,
                name: customer.name,
                phone: customer.phone,
                email: customer.email,
              }
            else
              {}
            end
          end

          def receiver_info
            {
              name: object&.name,
              phone: object&.phone,
            }
          end

          def status
            object.status.order_type&.humanize
          end

          def shipping_type
            object.shipping_type&.humanize
          end

          def shipping_type_id
            CustomerOrder::shipping_types[object.shipping_type]
          end

          def pay_type
            object.pay_type&.humanize
          end

          def section
            schedule = object&.partner&.schedule
            case schedule
            when 'sat_mon_wed'
              'A'
            when 'sun_tues_thurs'
              'B'
            else
              'D'
            end
          end

          def address
            @address ||= object&.partner&.address
          end

          def is_returnable
            return true if (object.status.completed? || object.status.partially_returned?) && object.completed_order_status_date + 7.day >= Date.today

            false
          end

          def distributor_name
            object.distributor&.name
          end

          def distributor_id
            object.distributor&.id
          end
        end
      end
    end
  end
end
