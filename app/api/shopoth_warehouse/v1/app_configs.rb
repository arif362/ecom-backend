module ShopothWarehouse
  module V1
    class AppConfigs < ShopothWarehouse::Base
      resource :app_configs do
        desc 'App version update.'
        params do
          requires :app_type, type: String
          requires :version_config, type: Hash
        end
        put '/version' do
          unless %w(sr_app rider_app partner_app ecom_app).include?(params[:app_type])
            error!(success_response_with_json("Please provide app type like: 'sr_app or rider_app or partner_app or ecom_app'",
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          configuration = Configuration.find_by(key: params[:app_type])
          unless configuration
            error!(success_response_with_json('App configuration not found.', HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:OK])
          end

          unless params[:version_config].keys == Configuration::ECOM_APP.stringify_keys.keys
            error!(success_response_with_json("Please provide version_config params keys like: #{Configuration::ECOM_APP.keys}",
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          configuration.update!(version_config: params[:version_config])
          success_response_with_json('Successfully updated app configuration.', HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to update app configuration due to #{error.message}"
          error!(failure_response_with_json('Unable to update app configuration.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
