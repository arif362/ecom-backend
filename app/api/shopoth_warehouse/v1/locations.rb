module ShopothWarehouse
  module V1
    class Locations < ShopothWarehouse::Base

      resource :locations do

        # INDEX *************************************************

        params do
          use :pagination, per_page: 50
          optional :skip_pagination, type: Boolean
        end

        desc 'Get all locations.'
        get do
          warehouse = @current_staff.warehouse
          if warehouse.present?
            locations_response = warehouse.locations&.sort_by { |k| k[:code] }&.as_json(except: %i(created_at updated_at), include: { warehouse: { only: %i(id name), include: { address: { only: %i(id district_id) } } } })
            # TODO: Need to Optimize Query
            params[:skip_pagination].present? ? paginate(Kaminari.paginate_array(locations_response)) : locations_response
          else
            respond_with_json "Warehouse Not Found!"
          end
        rescue StandardError => ex
          respond_with_json("Unable to Show Location list due to #{ex.message}", HTTP_CODE[:INTERNAL_SERVER_ERROR])
        end

        desc 'Get locations for a specific variant.'
        get '/variants/:id' do
          variant = Variant.find_by(id: params[:id])
          unless variant
            error!(failure_response_with_json('Variant not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          warehouse_variant = variant.warehouse_variants.find_by(warehouse: @current_staff.warehouse)
          wv_locations = warehouse_variant&.warehouse_variants_locations&.where('quantity > 0')&.map do |wv_location|
            {
              id: wv_location.location_id,
              code: wv_location.location&.code,
              quantity: wv_location.quantity,
            }
          end&.compact&.uniq
          success_response_with_json('Successfully fetched location list.', HTTP_CODE[:OK],
                                     wv_locations&.sort_by { |k| k[:code] })
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to Show Location list due to: #{error.message}"
          error!(failure_response_with_json('Unable to Show Location list.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        # CREATE ************************************************
        desc 'Create a new location.'
        params do
          requires :location, type: Hash do
            requires :code, type: String
          end
        end

        post do
          warehouse = @current_staff.warehouse
          location = warehouse.locations.new(params[:location].merge!(created_by_id: @current_staff.id))
          location if location.save!
          location.as_json(except: %i(created_at updated_at), include: { warehouse: { only: %i(id name), include: { address: { only: %i(id district_id) } } } })
        rescue StandardError => error
          error!(failure_response_with_json("Unable to create Location due to: #{error.message}",
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Update a specific Location.'
        put ':id' do
          warehouse = @current_staff.warehouse
          location = if warehouse.warehouse_type == Warehouse::WAREHOUSE_TYPES[:central]
                       Location.find(params[:id])
                     else
                       warehouse.locations.find(params[:id])
                     end
          location.update!(params[:location])
          location.as_json(except: %i(created_at updated_at), include: { warehouse: { only: %i(id name), include: { address: { only: %i(id district_id) } } } })
        rescue StandardError => error
          error!(failure_response_with_json("Unable to update location due to #{error.message}",
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        # Single  **********
        desc 'Single location'
        get ':id' do
          warehouse = @current_staff&.warehouse
          location = if check_wh_warehouse
                       Location.find(params[:id])
                     else
                       warehouse&.locations&.find(params[:id])
                     end
          ShopothWarehouse::V1::Entities::Locations.represent(location, warehouse: warehouse)
        rescue => ex
          error!("Unable to find location type due to #{ex.message}")
        end

        # Delete Locaiton ***********
        desc 'Delete location'
        delete ':id' do
          warehouse = @current_staff.warehouse
          if warehouse.present?
            if warehouse.warehouse_type == Warehouse::WAREHOUSE_TYPES[:central]
              location = Location.find(params[:id])
              location.destroy!
            else
              location = warehouse.locations.find(params[:id])
              location.destroy!
            end
          end
          respond_with_json("Delete Success!", HTTP_CODE[:OK])
        rescue => ex
          error!("Unable to find location type due to #{ex.message}")
        end

        desc 'location wise variants'
        get ':id/variants' do
          location_id = params[:id]
          warehouse = @current_staff.warehouse
          location = Location.find_by(id: location_id, warehouse: warehouse)
          error! respond_with_json('incorrect location or warehouse', HTTP_CODE[:NOT_FOUND]) unless location.present?

          warehouse_variants = location.warehouse_variants_locations.map(&:warehouse_variant).uniq
          present warehouse_variants, with: ShopothWarehouse::V1::Entities::WarehouseVariants
        rescue => ex
          error! respond_with_json("Unable to fetch variants due to #{ex}", HTTP_CODE[:NOT_FOUND])
        end

        desc 'Location transfer mechanism.'
        params do
          requires :present_location_id, type: Integer
          requires :transfer_location_id, type: Integer
          requires :variant_id, type: Integer
          requires :quantity, type: Integer
        end
        post '/transfer' do
          quantity = params[:quantity]
          present_location_id = params[:present_location_id]
          transfer_location_id = params[:transfer_location_id]
          variant = Variant.find_by(id: params[:variant_id])
          unless variant
            error!(respond_with_json('Variant not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          if present_location_id == transfer_location_id
            error!(respond_with_json("Can't transfer quantity because same location given.",
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
          end

          present_location = Location.find_by(id: present_location_id)
          transfer_location = Location.find_by(id: transfer_location_id)

          unless present_location || transfer_location
            error!(respond_with_json('Unable to find location.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          warehouse_variant = @current_staff.warehouse.warehouse_variants.find_by(variant: variant)

          unless warehouse_variant
            error!(respond_with_json('Warehouse variant not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          present_wv_location = warehouse_variant.warehouse_variants_locations.find_by!(location_id: present_location.id)
          present_wv_location_quantity = present_wv_location.quantity

          if present_wv_location_quantity < quantity
            error!(respond_with_json("Can't transferred because current location's quantity is less than transfer quantity",
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
          end
          transfer_wv_location = warehouse_variant.warehouse_variants_locations.find_or_create_by!(location_id: transfer_location.id)
          present_wv_location.update!(quantity: present_wv_location_quantity - quantity)
          transfer_wv_location.update!(quantity: transfer_wv_location.quantity + quantity)
          status :ok
          respond_with_json('Successfully transferred quantity.', HTTP_CODE[:OK])
        rescue StandardError => error
          error!(respond_with_json("Failed due to #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
