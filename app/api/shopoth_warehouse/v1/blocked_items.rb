module ShopothWarehouse
  module V1
    class BlockedItems < ShopothWarehouse::Base
      helpers do
        def locations(warehouse_variant)
          wv_locations = warehouse_variant&.warehouse_variants_locations&.where('quantity > 0')
          wv_locations&.map do |wv_location|
            {
              id: wv_location.location_id,
              code: wv_location.location.code,
              quantity: wv_location.quantity,
            }
          end || []
        end

        def quantity_check(blocked_item, warehouse_variant, quantity)
          remaining_quantity = blocked_item.blocked_quantity - (blocked_item.garbage_quantity + blocked_item.unblocked_quantity)
          return false if remaining_quantity < quantity || warehouse_variant.blocked_quantity < quantity

          true
        end

        def garbage_quantity_update(blocked_item, warehouse_variant, quantity)
          ActiveRecord::Base.transaction do
            blocked_item.update!(garbage_quantity: blocked_item.garbage_quantity + quantity)
            warehouse_variant.update!(blocked_quantity: warehouse_variant.blocked_quantity - quantity)
            warehouse_variant.save_stock_change('garbage_blocked_sku', quantity, blocked_item, 'blocked_quantity_change', 'garbage_quantity_change')
          end
        end

        def unblocked_quantity_update(blocked_item, warehouse_variant, wv_location, quantity)
          ActiveRecord::Base.transaction do
            blocked_item.update!(unblocked_quantity: blocked_item.unblocked_quantity + quantity)
            warehouse_variant.update!(
              blocked_quantity: warehouse_variant.blocked_quantity - quantity,
              available_quantity: warehouse_variant.available_quantity + quantity,
            )
            wv_location.update!(quantity: wv_location.quantity + quantity)
            warehouse_variant.save_stock_change('sku_unblock', quantity, blocked_item, 'blocked_quantity_change', 'available_quantity_change')
          end
        end

        def update_warehouse_quantity(blocked_item, warehouse_variant, wv_location, quantity)
          warehouse_variant.update!(
            available_quantity: warehouse_variant.available_quantity - quantity,
            blocked_quantity: warehouse_variant.blocked_quantity + quantity,
          )
          wv_location.update!(quantity: wv_location.quantity - quantity)
          warehouse_variant.save_stock_change('sku_block', quantity, blocked_item, 'available_quantity_change', 'blocked_quantity_change')
        end
      end

      resources :blocked_items do
        params do
          use :pagination, per_page: 50
        end

        get do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : 1.month.ago
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc : Time.now
          sku = params[:sku]
          failed_reason = params[:failed_reason]
          block_items = @current_staff.warehouse.blocked_items.pending

          if start_date_time.present? && end_date_time.present?
            block_items = block_items.where('blocked_items.created_at >= ? AND blocked_items.created_at <= ?', start_date_time.beginning_of_day, end_date_time.end_of_day)
          end

          if failed_reason.present?
            block_reason = BlockedItem.blocked_reasons[params[:failed_reason]]
            block_items = block_items.where('blocked_reason = ?', block_reason)
          end

          if sku.present?
            block_items = block_items.includes(:variant).where(variants: { sku: sku }).references(:variants)
          end
          # TODO: Need to Optimize Query
          present paginate(Kaminari.paginate_array(block_items)), with: ShopothWarehouse::V1::Entities::BlockedItems
        end

        desc 'Create Block Item.'
        params do
          requires :variant_id, type: Integer
          requires :blocked_quantity, type: Integer
          requires :blocked_reason, type: String
          requires :location_id, type: Integer
          optional :note, type: String
        end

        post do
          quantity = params[:blocked_quantity]
          location = @current_staff.warehouse.locations.find_by(id: params[:location_id])
          unless location
            error!(respond_with_json('Location not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          # TODO: We should bring those warehouse_variant which variant isn't deleted. Need to be sure about that.
          # For now warehouse_variant fetch using variant_id is OK.
          warehouse_variant = @current_staff.warehouse.warehouse_variants.find_by(variant_id: params[:variant_id])
          unless warehouse_variant
            error!(respond_with_json('Warehouse variant not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          wv_location = warehouse_variant.warehouse_variants_locations.find_by(location: location)
          unless wv_location
            error!(respond_with_json('Warehouse_variant_location not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          params.delete(:location_id)
          if warehouse_variant.available_quantity >= quantity && wv_location.quantity >= quantity
            ActiveRecord::Base.transaction do
              blocked_item = @current_staff.warehouse.blocked_items.new(params.merge!(created_by_id: @current_staff.id))
              blocked_item.save!
              update_warehouse_quantity(blocked_item, warehouse_variant, wv_location, quantity)
            end
            respond_with_json("Successfully blocked #{quantity} quantity.", HTTP_CODE[:OK])
          else
            respond_with_json('Wrong quantity given to block.', HTTP_CODE[:NOT_ACCEPTABLE])
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to block this variant due to: #{error.message}"
          error!(respond_with_json('Unable to block this variant', HTTP_CODE[:FORBIDDEN]),
                 HTTP_CODE[:FORBIDDEN])
        end

        get 'item_info/:id' do
          warehouse_variant = @current_staff.warehouse.warehouse_variants.find_by(variant_id: params[:id])
          if warehouse_variant.present?
            locations = locations(warehouse_variant)
            variant = warehouse_variant.variant
            {
              variant: {
                id: variant.id,
                title: variant&.product&.title,
                sku: variant.sku,
                available_quantity: warehouse_variant.available_quantity,
              },
              locations: locations,
              blocked_reasons: BlockedItem.blocked_reasons.collect { |key, value| { key: key, value: key.humanize } },
            }
          else
            error! respond_with_json('Unable to find the sku, please purchase it first.', HTTP_CODE[:NOT_FOUND])
          end
        rescue => ex
          error!("Unable to find sku due to #{ex.message}")
        end

        get '/blocked_reasons' do
          BlockedItem.blocked_reasons.collect { |key, value| { key: key, value: key.humanize } }
        end

        desc 'Unblock variant quantity.'
        put '/unblock/:id' do
          quantity = params[:quantity]
          blocked_item = @current_staff.warehouse&.blocked_items&.pending&.find_by(id: params[:id])
          unless blocked_item
            error!(respond_with_json('Blocked items not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          unless quantity.positive?
            error!(respond_with_json('Quantity must be positive.', HTTP_CODE[:FORBIDDEN]), HTTP_CODE[:FORBIDDEN])
          end

          warehouse_variant = @current_staff.warehouse.warehouse_variants.find_by(variant: blocked_item.variant)
          unless warehouse_variant
            error!(respond_with_json('Warehouse Variant not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          location = @current_staff.warehouse.locations.find_by(id: params[:location_id])
          unless location
            error!(respond_with_json('Location not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          wv_location = warehouse_variant.warehouse_variants_locations.find_or_create_by(location: location)
          if quantity_check(blocked_item, warehouse_variant, quantity) == true
            unblocked_quantity_update(blocked_item, warehouse_variant, wv_location, quantity)
            respond_with_json("Successfully unblocked #{quantity} quantity.", HTTP_CODE[:OK])
          else
            respond_with_json('Wrong quantity given to unblock.', HTTP_CODE[:NOT_ACCEPTABLE])
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to unblock this variant due to: #{error.message}"
          error!(respond_with_json('Unable to unblock this variant.', HTTP_CODE[:FORBIDDEN]),
                 HTTP_CODE[:FORBIDDEN])
        end

        desc 'Move variant quantity into garbage.'
        put '/garbage/:id' do
          quantity = params[:quantity]
          blocked_item = @current_staff.warehouse&.blocked_items&.pending&.find_by(id: params[:id])
          unless blocked_item
            error!(respond_with_json('Blocked items not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          unless quantity.positive?
            error!(respond_with_json('Quantity must be positive.', HTTP_CODE[:FORBIDDEN]), HTTP_CODE[:FORBIDDEN])
          end

          warehouse_variant = @current_staff.warehouse.warehouse_variants.find_by(variant: blocked_item.variant)
          unless warehouse_variant
            error!(respond_with_json('Warehouse Variant not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          if quantity_check(blocked_item, warehouse_variant, quantity) == true
            garbage_quantity_update(blocked_item, warehouse_variant, quantity)
            respond_with_json("#{quantity} quantity moved into garbage.", HTTP_CODE[:OK])
          else
            respond_with_json('Wrong quantity given to move into garbage.', HTTP_CODE[:NOT_ACCEPTABLE])
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to move this quantity into garbage due to: #{error.message}"
          error!(respond_with_json('Unable to move this quantity into garbage.', HTTP_CODE[:FORBIDDEN]),
                 HTTP_CODE[:FORBIDDEN])
        end

        get '/export' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : 1.month.ago
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc : Time.now
          sku = params[:sku]
          failed_reason = params[:failed_reason]

          block_items = @current_staff.warehouse.blocked_items.pending

          if start_date_time.present? && end_date_time.present?
            block_items = block_items.where('blocked_items.created_at >= ? AND blocked_items.created_at <= ?', start_date_time.beginning_of_day, end_date_time.end_of_day)
          end

          if failed_reason.present?
            block_reason = BlockedItem.blocked_reasons[params[:failed_reason]]
            block_items = block_items.where('blocked_reason = ?', block_reason)
          end

          if sku.present?
            block_items = block_items.includes(:variant).where(variants: { sku: sku }).references(:variants)
          end

          present block_items, with: ShopothWarehouse::V1::Entities::BlockedItemsExport

        rescue => ex
          error!("Unable to find blocked items due to #{ex.message}")
        end

        get '/:id' do
          block_item = @current_staff.warehouse&.blocked_items&.find_by(id: params[:id])
          if block_item.present?
            locations = @current_staff&.warehouse&.locations
            {
              id: block_item.id,
              blocked_quantity: block_item.blocked_quantity,
              garbage_quantity: block_item.garbage_quantity,
              unblocked_quantity: block_item.unblocked_quantity,
              remaining_blocked_quantity: block_item.blocked_quantity - ((block_item.garbage_quantity + block_item.unblocked_quantity)),
              locations: locations,
              created_by:
                {
                  id: block_item.created_by_id,
                  name: Staff.unscoped.find_by(id: block_item.created_by_id)&.name,
                },
            }
          else
            respond_with_json('Not found blocked item', HTTP_CODE[:NOT_FOUND])
          end
        rescue => ex
          error!("Unable to find blocked item due to #{ex.message}")
        end
      end
    end
  end
end