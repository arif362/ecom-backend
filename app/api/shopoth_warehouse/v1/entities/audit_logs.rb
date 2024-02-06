# frozen_string_literal: true

module ShopothWarehouse
  module V1
    module Entities
      class AuditLogs < Grape::Entity
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
          case object.auditable_type
          when 'Product'
            sku_type_map
            warranty_type_map
          when 'Variant'
            discount_type_map
            bundle_status_map
          else
            object.audited_changes
          end
        end

        def sku_type_map
          return object.audited_changes unless object.audited_changes['sku_type'].present?

          previous = object.action == 'update' ? Product.sku_types.keys[object.audited_changes['sku_type'][0]] : nil
          current = Product.sku_types.keys[object.audited_changes['sku_type'][1]]
          object.audited_changes.merge!({ 'sku_type': [previous, current] })
        end

        def warranty_type_map
          return object.audited_changes unless object.audited_changes['warranty_type'].present?

          previous = object.action == 'update' ? Product.warranty_types.keys[object.audited_changes['warranty_type'][0]] : nil
          current = Product.warranty_types.keys[object.audited_changes['warranty_type'][1]]
          object.audited_changes.merge!({ 'warranty_type': [previous, current] })
        end

        def discount_type_map
          return object.audited_changes unless object.audited_changes['discount_type'].present?

          previous = object.action == 'update' ? Variant.discount_types.keys[object.audited_changes['discount_type'][0]] : nil
          current = Variant.discount_types.keys[object.audited_changes['discount_type'][1]]
          object.audited_changes.merge!({ 'discount_type': [previous, current] })
        end

        def bundle_status_map
          return object.audited_changes unless object.audited_changes['bundle_status'].present?

          previous = object.action == 'update' ? Variant.bundle_statuses.keys[object.audited_changes['bundle_status'][0]] : nil
          current = Variant.bundle_statuses.keys[object.audited_changes['bundle_status'][1]]
          object.audited_changes.merge!({ 'bundle_status': [previous, current] })
        end

      end
    end
  end
end
