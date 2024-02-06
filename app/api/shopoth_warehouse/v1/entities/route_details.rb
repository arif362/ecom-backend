module ShopothWarehouse
  module V1
    module Entities
      class RouteDetails < Grape::Entity
        expose :id
        expose :title
        expose :bn_title
        expose :phone
        expose :sr_name
        expose :sr_point
        expose :route_device
        expose :distributor_id
        expose :distributor_name
        expose :distributor_bn_name
        expose :created_by

        def route_device
          route_device = object.route_device
          return {} unless route_device.present?

          {
            id: route_device.device_id,
            device_id: route_device.device_id,
            route_id: route_device.route_id,
          }
        end

        def distributor
          @distributor ||= object&.distributor
        end

        def distributor_name
          distributor&.name
        end

        def distributor_bn_name
          distributor&.bn_name
        end

        def created_by
          {
            id: object.created_by_id,
            name: Staff.unscoped.find_by(id: object.created_by_id)&.name,
          }
        end
      end
    end
  end
end
