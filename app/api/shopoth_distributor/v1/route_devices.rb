module ShopothDistributor
  module V1
    class RouteDevices < ShopothDistributor::Base
      resource '/route_devices' do
        desc 'Connect sr route device'
        params do
          requires :route_device, type: Hash do
            requires :unique_id, type: String
            requires :password_hash, type: String
            requires :route_id, type: Integer
          end
        end

        post '/connect' do
          route = @current_distributor.routes.find_by(id: params[:route_device][:route_id])
          unless route
            error!(failure_response_with_json('Route not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          route_device = RouteDevice.find_by(unique_id: params[:route_device][:unique_id])
          unless route_device
            error!(failure_response_with_json('Route device not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          if route_device.route
            error!(failure_response_with_json('A devise is already connected.', HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:OK])
          end

          route_device.update!(route: route, password: params[:route_device][:password_hash])
          success_response_with_json('Successfully connected.', HTTP_CODE[:OK], route_device)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to connect route device due to: #{error.message}"
          error!(failure_response_with_json('Unable to connect route device.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Disconnect a sr device.'
        put '/:route_id/disconnect' do
          route = @current_distributor.routes.find_by(id: params[:route_id])
          unless route
            error!(failure_response_with_json('Route not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          unless route.route_device
            error!(failure_response_with_json('Route has no connected device.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          route.route_device.update!(route_id: nil)
          success_response_with_json('Disconnected successfully.', HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to disconnect route device due to: #{error.message}"
          error!(failure_response_with_json('Unable to disconnect route device.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
