# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class Distributors < ShopothWarehouse::Base
      helpers do
        def validate_distributor_params(params, distributor = nil)
          if distributor
            return_params = {
              name: params[:name].present? ? params[:name] : distributor.name,
              bn_name: params[:bn_name].present? ? params[:bn_name] : distributor.bn_name,
              email: params[:email].present? ? params[:email] : distributor.email,
              address: params[:address].present? ? params[:address] : distributor.address,
              code: params[:code].present? ? params[:code] : distributor.code,
              status: params[:status].present? ? params[:status] : distributor.status,
            }
            if params[:password].present? && params[:password_confirmation].present?
              return_params[:password] = params[:password]
              return_params[:password_confirmation] = params[:password_confirmation]
            end
            return_params
          else
            {
              name: params[:name], bn_name: params[:bn_name], email: params[:email],
              password: params[:password], phone: params[:phone],
              password_confirmation: params[:password_confirmation],
              address: params[:address], code: params[:code], status: params[:status],
            }
          end
        end

        def check_password(params)
          if params[:password].present? && params[:password_confirmation].present? && params[:password] != params[:password_confirmation]
            error!(failure_response_with_json('Password needs to be same.',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
        end
      end
      resource :distributors do
        desc 'Get all distributor.'
        params do
          use :pagination, per_page: 50
        end
        get do
          distributors = check_wh_warehouse ? Distributor.all : @current_staff&.warehouse&.distributors
          # TODO: Need to Optimize Query
          response = ShopothWarehouse::V1::Entities::Distributors.represent(
            paginate(Kaminari.paginate_array(distributors)),
          )
          success_response_with_json('Successfully fetched distributors.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch distributors due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch distributors.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Get a specific distributor details.'
        get '/:id' do
          distributor = @current_staff.warehouse.distributors.find_by(id: params[:id])
          unless distributor
            error!(failure_response_with_json('Distributor not found', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          response = ShopothWarehouse::V1::Entities::Distributors.represent(distributor)
          success_response_with_json('Successfully fetch distributor.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch distributor due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch distributor.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        desc 'Create a new distributor.'
        params do
          requires :name, type: String
          requires :bn_name, type: String
          requires :email, type: String
          requires :password, type: String
          requires :password_confirmation, type: String
          requires :phone, type: String
          requires :address, type: String
          requires :code, type: String
          requires :status, type: String
        end
        post do
          check_password(params)
          params.merge!(created_by_id: @current_staff.id)
          @current_staff.warehouse.distributors.create!(validate_distributor_params(params))
          success_response_with_json('Successfully created distributor.', HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create distributor due to: #{error.message}"
          error!(failure_response_with_json('Unable to create distributor.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Update a distributor.'
        put '/:id' do
          distributor = @current_staff.warehouse.distributors.find_by(id: params[:id])
          unless distributor
            error!(failure_response_with_json('Distributor not found', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          check_password(params)
          distributor.update!(validate_distributor_params(params, distributor))
          success_response_with_json('Successfully updated distributor.', HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to update distributor due to: #{error.message}"
          error!(failure_response_with_json('Unable to update distributor.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Delete a distributor.'
        delete '/:id' do
          distributor = @current_staff.warehouse.distributors.find_by(id: params[:id])
          unless distributor
            error!(failure_response_with_json('Distributor not found', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          if distributor.routes.count.positive? || distributor.return_customer_orders.count.positive?
            error!(failure_response_with_json("Can't delete distributor, distributor has routes or return_customer_orders",
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          success_response_with_json('Successfully deleted distributor.', HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to delete distributor due to: #{error.message}"
          error!(failure_response_with_json('Unable to delete distributor.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
