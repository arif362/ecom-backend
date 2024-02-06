module ShopothCustomerCare
  module V1
    class Districts < ShopothCustomerCare::Base

      resource :districts do

        # INDEX *************************************************
        desc 'Get all Districts'
        get do
          districts = District.where(is_deleted: false)
          districts.order(created_at: :desc)
        end

        # CREATE ************************************************
        desc 'Create a new District'
        params do
          requires :district, type: Hash do
            requires :name, type: String
            requires :bn_name, type: String
          end
        end

        post do
          district = District.new(params[:district])
          district if district.save!
        rescue StandardError => error
          error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # UPDATE ************************************************
        desc 'Update a District'

        route_param :id do
          put do
            district = District.find(params[:id])
            district if district.update!(params[:district])
          rescue StandardError => error
            error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        # DELETE ************************************************
        desc 'Delete a District'

        route_param :id do
          delete do
            District.find(params[:id]).update!(is_deleted: true)
            respond_with_json("Successfully deleted District with id #{params[:id]}", HTTP_CODE[:OK])
          rescue StandardError => error
            error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
