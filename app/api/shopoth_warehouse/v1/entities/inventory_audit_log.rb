# frozen_string_literal: true

module ShopothWarehouse
  module V1
    module Entities
      class InventoryAuditLog < Grape::Entity
        expose :id
        expose :action
        expose :created_by
        expose :created_at
        expose :audited_changes
        expose :inventory

        def created_by
          Staff.unscoped.find_by(id: object.user_id)
        end

        def inventory
          WarehouseVariant.where(variant_id: object.auditable_id)&.map do |wv|
            {
              variant_id: wv.variant_id,
              warehouse_id: wv.warehouse_id,
              warehouse_variant_id: wv.id,
              stock_changes_log: wv.stock_changes,
              location_changes: wv.warehouse_variants_locations&.map do |wvl|
                {
                  location_code: wvl.location&.code,
                  log: ShopothWarehouse::V1::Entities::AuditLogs.represent(wvl.audits),
                }
              end,
            }
          end
        end
      end
    end
  end
end
