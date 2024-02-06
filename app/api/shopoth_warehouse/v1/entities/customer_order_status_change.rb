module ShopothWarehouse
  module V1
    module Entities
      class CustomerOrderStatusChange < Grape::Entity
        expose :id
        expose :order_status
        expose :created_at
        expose :changed_by

        def order_status
          OrderStatus.find_by(id: object.order_status_id)&.admin_order_status&.humanize
        end

        def changed_by
          order_status_change = changed_by_user_info
          {
            id: object.changed_by_id,
            name: order_status_change[:name],
            email: order_status_change[:email],
            phone_number: order_status_change[:phone_number],
            staffable_type: order_status_change[:staffable_type],
            staffable_id: order_status_change[:staffable_id],
            changed_by_type: object.changed_by_type,
          }
        end

        def changed_by_user_info
          changed_by_user = object.changed_by_type.constantize.unscoped.find_by(id: object.changed_by_id)
          case object.changed_by_type
          when 'Rider', 'Partner'
            {
              name: changed_by_user.name,
              email: changed_by_user.email,
              phone_number: changed_by_user.phone,
              staffable_type: object.changed_by_type,
              staffable_id: object.changed_by_id,
            }
          when 'RouteDevice'
            {
              name: changed_by_user.route.title,
              email: '',
              phone_number: changed_by_user.route.phone,
              staffable_type: object.changed_by_type,
              staffable_id: object.changed_by_id,
            }
          when 'Route'
            {
              name: changed_by_user.title,
              email: '',
              phone_number: changed_by_user.phone,
              staffable_type: object.changed_by_type,
              staffable_id: object.changed_by_id,
            }
          when 'Staff'
            {
              name: changed_by_user.name,
              email: changed_by_user.email,
              phone_number: '',
              staffable_type: changed_by_user.staffable_type,
              staffable_id: changed_by_user.staffable_id,
            }
          end
        end
      end
    end
  end
end
