module ShopothCustomerCare
  module V1
    class Thanas < ShopothCustomerCare::Base

      resource :thanas do

        # INDEX *************************************************
        desc 'Get all Thanas'
        get do
          thanas = Thana.where(is_deleted: false)
          thanas.order(created_at: :desc)
        end

        desc 'Get all thana based on district_id.'
        params do
          requires :district_id, type: Integer
        end
        get '/search' do
          Thana.where(district_id: params[:district_id])
        end

        # CREATE ************************************************
        desc 'Create a new Thana'
        params do
          requires :thana, type: Hash do
            requires :district_id, type: Integer
            requires :name, type: String
            requires :bn_name, type: String
          end
        end

        post do
          thana = Thana.new(params[:thana])
          thana if thana.save!
        rescue StandardError => error
          error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # UPDATE ************************************************
        desc 'Update a Thana'

        route_param :id do
          put do
            thana = Thana.find(params[:id])
            thana if thana.update!(params[:thana])
          rescue StandardError => error
            error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        # DELETE ************************************************
        desc 'Delete a Thana'

        route_param :id do
          delete do
            Thana.find(params[:id]).update!(is_deleted: true)
            respond_with_json("Successfully deleted Thana with id #{params[:id]}", HTTP_CODE[:OK])
          rescue StandardError => error
            error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
