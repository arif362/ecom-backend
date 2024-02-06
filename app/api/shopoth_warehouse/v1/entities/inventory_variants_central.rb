# frozen_string_literal: true

module ShopothWarehouse
  module V1
    module Entities
      class InventoryVariantsCentral < Grape::Entity
        include ShopothWarehouse::V1::Helpers::ImageHelper
        expose :id
        expose :product_title
        expose :sku
        expose :trade_price
        expose :mrp
        # expose :price_distribution
        expose :available_quantity
        expose :booked_quantity
        expose :blocked_quantity
        expose :packed_quantity
        expose :in_transit_quantity
        expose :in_partner_quantity
        expose :qc_quantity
        expose :total_count
        expose :distribution_margin

        def available_quantity
          warehouse_variant&.available_quantity || 0
        end

        def booked_quantity
          warehouse_variant&.booked_quantity || 0
        end

        def blocked_quantity
          warehouse_variant&.blocked_quantity || 0
        end

        def packed_quantity
          warehouse_variant&.packed_quantity || 0
        end

        def in_transit_quantity
          warehouse_variant&.in_transit_quantity || 0
        end

        def in_partner_quantity
          warehouse_variant&.in_partner_quantity || 0
        end

        def product_title
          Product.unscoped.find_by(id: object.product_id, is_deleted: false)&.title || ''
        end

        def qc_quantity
          warehouse = Warehouse.find(options[:warehouse_id])
          if warehouse.warehouse_type === Warehouse::WAREHOUSE_TYPES[:central]
            purchase_order_ids = WhPurchaseOrder.all.ids
            object.failed_qcs.where('failable_id in (?) AND failable_type = ?', purchase_order_ids, 'WhPurchaseOrder').sum{ |failed_qc| failed_qc.open_quantity }
          elsif warehouse.warehouse_type === Warehouse::WAREHOUSE_TYPES[:distribution] || warehouse.warehouse_type === Warehouse::WAREHOUSE_TYPES[:member] ||
            warehouse.warehouse_type === Warehouse::WAREHOUSE_TYPES[:b2b]
            purchase_order_ids = warehouse.dh_purchase_orders.ids
            object.failed_qcs.where('failable_id in (?) AND failable_type = ?', purchase_order_ids, 'DhPurchaseOrder').sum{ |failed_qc| failed_qc.open_quantity }
          end
          # object.failed_qcs.where('warehouse_id = ?', options[:warehouse_id]).sum(:quantity)
        end

        def total_quantity
          available_quantity + booked_quantity + packed_quantity + in_transit_quantity + qc_quantity
        end

        def mrp
          total_quantity * object.effective_mrp
        end

        def total_count
          total_quantity
        end

        def price_distribution
          object.price_distribution.present? ? total_quantity * object.price_distribution : 0
        end

        def trade_price
          total_count = total_quantity
          remaining_quantity = total_count
          total_price = 0
          index = 1
          last_line_item_id = 0
          while remaining_quantity > 0
            line_item = WhPurchaseOrder.joins(:line_items)
                                       .select('line_items.id, line_items.price, line_items.received_quantity')
                                       .where('line_items.variant_id = ?', object.id).order(:created_at)
                                       .last(index).first

            # this break is only for wrong data or inconsistent data pass.
            break if line_item.nil? or last_line_item_id == line_item.id

            if line_item.received_quantity < remaining_quantity
              total_price += line_item.received_quantity * line_item.price
              remaining_quantity -= line_item.received_quantity
            else
              total_price += remaining_quantity * line_item.price
              remaining_quantity = 0
            end
            index += 1
            last_line_item_id = line_item.id
          end
          total_price
        end

        def distribution_margin
          (mrp * 1.5) / 100
        end

        def warehouse_variant
          @warehouse_variant ||= object.warehouse_variants&.find_by(warehouse_id: warehouse_id)
        end

        def warehouse_id
          @warehouse_id ||= options[:warehouse_id]
        end
      end
    end
  end
end
