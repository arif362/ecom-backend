module ShopothWarehouse
  module V1
    class WarehouseVariantsLocations < ShopothWarehouse::Base
      helpers do
        def warehouse_stock_update(warehouse, line_item, location, type = '')
          warehouse_variant = warehouse.warehouse_variants.find_or_create_by!(variant: line_item.variant)
          warehouse_variants_location = warehouse_variant.warehouse_variants_locations.find_or_create_by!(location: location)
          warehouse_variant.update!(available_quantity: warehouse_variant.available_quantity + line_item.qc_passed, location_pending_quantity: warehouse_variant.location_pending_quantity - line_item.qc_passed)
          warehouse_variants_location.update!(quantity: warehouse_variants_location.quantity + line_item.qc_passed)
          transaction_type = type == 'rto' ? 'location_assign_after_rto_qc' : 'location_assign_after_inbound_qc'
          warehouse_variant.save_stock_change(transaction_type, line_item.qc_passed, line_item.itemable, 'location_pending_quantity_change', 'available_quantity_change')
        end

        def unpacked_returned_update(line_item, location, warehouse, return_order)
          warehouse_variant = line_item.variant.warehouse_variants.find_by!(warehouse: warehouse)
          wv_location = warehouse_variant.warehouse_variants_locations.find_or_create_by!(location: location)
          # warehouse_variant.update!(available_quantity: warehouse_variant.available_quantity + 1)
          wv_location.update!(quantity: wv_location.quantity + (return_order.customer_order.b2b? ? return_order.quantity : 1))
          return_order.update_inventory_and_stock_changes('available_quantity', 'return_location_pending_quantity')
          1
        end

        def packed_returned_update(locations, line_items, warehouse, warehouse_locations, return_order)
          location_quantity_updated = 0
          locations.each do |location|
            line_item = line_items.find(location[:line_item_id])
            location = warehouse_locations.find(location[:location_id])
            warehouse_variant = line_item.variant.warehouse_variants.find_by!(warehouse: warehouse)
            wv_location = warehouse_variant.warehouse_variants_locations.find_or_create_by!(location: location)
            # warehouse_variant.update!(available_quantity: warehouse_variant.available_quantity + line_item.quantity)
            wv_location.update!(quantity: wv_location.quantity + line_item.quantity)
            return_order.update_inventory_and_stock_changes('available_quantity', 'return_location_pending_quantity', line_item)
            location_quantity_updated += 1
          end
          location_quantity_updated
        end
      end
      resource :warehouse_variants_locations do
        # CREATE ************************************************
        desc 'Assign location to line items.'
        params do
          requires :warehouse_variants_locations, type: Hash do
            requires :line_item_id, type: Integer
            requires :location_id, type: Integer
            optional :order_type, type: String
          end
        end

        post do
          warehouse_variants_locations = params[:warehouse_variants_locations]
          line_item = LineItem.find_by(id: warehouse_variants_locations[:line_item_id])
          unless line_item
            error!(respond_with_json('LineItem not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          location = @current_staff.warehouse.locations.find_by(id: warehouse_variants_locations[:location_id])
          unless location
            error!(respond_with_json('Location not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          if line_item.location.present?
            error! respond_with_json('Line Item already assigned!', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          else
            ActiveRecord::Base.transaction do
              warehouse_stock_update(@current_staff.warehouse, line_item, location, warehouse_variants_locations[:order_type])
              line_item.update!(location: location)
            end
            present line_item, with: ShopothWarehouse::V1::Entities::LineItems::ItemWithLocations,
                    warehouse: @current_staff.warehouse
          end
        rescue StandardError => error
          error! respond_with_json("Unable to create Warehouse Variant due to #{error.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Assign location of returned orders.'
        params do
          requires :return_order_id, type: Integer
          optional :rider_id, type: Integer
          optional :route_id, type: Integer
          requires :locations, type: Array do
            requires :line_item_id, type: Integer
            requires :location_id, type: Integer
          end
        end

        put '/return_assign' do
          warehouse = @current_staff.warehouse
          rider_id = params[:rider_id]
          route_id = params[:route_id]
          return_receiver = if rider_id.present?
                              warehouse.riders.find_by(id: rider_id)
                            elsif route_id.present?
                              warehouse.routes.find_by(id: route_id)
                            end

          unless return_receiver
            error!(respond_with_json('Rider/Route not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          location_quantity_updated = 0
          return_order = return_receiver.return_customer_orders.find(params[:return_order_id])
          line_items = return_order.customer_order.shopoth_line_items
          warehouse_locations = warehouse.locations

          ActiveRecord::Base.transaction do
            if return_order.unpacked? && return_order.relocation_pending?
              unpacked_location = params[:locations].first
              line_item = line_items.find(unpacked_location[:line_item_id])
              location = warehouse_locations.find(unpacked_location[:location_id])
              location_quantity_updated = unpacked_returned_update(line_item, location, warehouse, return_order)
            elsif return_order.packed? && return_order.relocation_pending?
              location_quantity_updated = packed_returned_update(params[:locations], line_items, warehouse,
                                                                 warehouse_locations, return_order)
            end

            if return_order.unpacked? && location_quantity_updated == 1
              return_order.update!(return_status: :completed, changeable: @current_staff)
              respond_with_json('Successfully updated location quantity.', HTTP_CODE[:OK])
            elsif return_order.packed? && location_quantity_updated == line_items.count
              return_order.update!(return_status: :completed, changeable: @current_staff)
              respond_with_json('Successfully updated location quantity.', HTTP_CODE[:OK])
            else
              fail ActiveRecord::Rollback
            end
          end
        rescue ActiveRecord::Rollback
          error!(respond_with_json("Cannot assign location for return_order id:#{return_order.id}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        rescue StandardError => error
          error! respond_with_json("Unable to create Warehouse Variant due to #{error.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
