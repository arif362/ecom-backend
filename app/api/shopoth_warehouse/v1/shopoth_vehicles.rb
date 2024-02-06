module ShopothWarehouse
  module V1
    class ShopothVehicles < ShopothWarehouse::Base

      resource :shopoth_vehicles do

        desc 'Return list of vehicles'
        get do
          ShopothVehicle.all
        end

        desc 'create a new vehicle'
        params do
          requires :vehicle_type, type: String
          requires :bn_vehicle_type, type: String
          requires :vehicle_number, type: String
          requires :bn_vehicle_number, type: String
          requires :company_name, type: String
          requires :bn_company_name, type: String
          requires :status, type: String
          requires :bn_status, type: String
          requires :driver_name, type: String
          requires :bn_driver_name, type: String
          requires :validity, type: String
          requires :bn_validity, type: String
        end

        post do
          shopoth_vehicle = ShopothVehicle.new(params)
          shopoth_vehicle if shopoth_vehicle.save!
        rescue StandardError
          error! respond_with_json('Unable to create Shopoth_Vehicle.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'get a vehicle'
        params do
          requires :id, type: Integer, desc: 'vehicle id'
        end

        route_param :id do
          get do
            shopoth_vehicle = ShopothVehicle.find_by(id: params[:id])
            shopoth_vehicle if shopoth_vehicle.present?
          rescue StandardError
            error! respond_with_json('Unable to find Shopoth_Vehicle.', HTTP_CODE[:NOT_FOUND])
          end
        end

        desc 'update a specific vehicle'
        route_param :id do
          put do
            shopoth_vehicle = ShopothVehicle.find_by(id: params[:id])
            shopoth_vehicle if shopoth_vehicle.update!(params)
          rescue StandardError
            error! respond_with_json('Unable to update Shopoth_Vehicle.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'delete a vehicle'
        params do
          requires :id, type: String, desc: 'logistic id'
        end

        delete ':id' do
          logistic = ShopothVehicle.find_by(id: params[:id])
          'Successfully deleted.' if logistic.destroy!
        rescue StandardError
          error! respond_with_json('Unable to delete Shopoth_Vehicle.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
