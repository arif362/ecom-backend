# frozen_string_literal: true

module ShopothWarehouse
  module V1
    module Entities
      class LineItemLog < Grape::Entity
        expose :id
        expose :action
        expose :auditable_id
        expose :auditable_type
        expose :created_by
        expose :created_at
        expose :audited_changes

        def created_by
          Staff.unscoped.find_by(id: object.user_id)
        end

        def audited_changes
          location_map
          reconcilation_status_map
        end

        def location_map
          return object.audited_changes unless object.audited_changes['location_id'].present?

          previous = Location.find_by(id: object.audited_changes['location_id'][0])&.code
          current = Location.find_by(id: object.audited_changes['location_id'][1])&.code
          object.audited_changes.merge!({ 'location_code': [previous, current] })
        end

        def reconcilation_status_map
          return object.audited_changes unless object.audited_changes['reconcilation_status'].present?

          previous = object.action == 'update' ? LineItem.reconcilation_statuses.keys[object.audited_changes['reconcilation_status'][0]] : nil
          current = LineItem.reconcilation_statuses.keys[object.audited_changes['reconcilation_status'][1]]
          object.audited_changes.merge!({ 'reconcilation_status': [previous, current] })
        end

      end
    end
  end
end
