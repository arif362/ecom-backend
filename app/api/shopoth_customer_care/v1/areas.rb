module ShopothCustomerCare
  module V1
    class Areas < ShopothCustomerCare::Base

      resource :areas do

        # INDEX *************************************************
        desc 'Get all Areas'
        get do
          Area.where(is_deleted: false)
        end

        desc 'Get all Area based on thana_id.'
        params do
          requires :thana_id, type: Integer
          optional :home_delivery, type: Boolean
        end
        get '/search' do
          if params[:home_delivery]
            Area.home_delivery_by_thana(params[:thana_id])
          else
            Area.where(thana_id: params[:thana_id])
          end
        end

        # CREATE ************************************************
        desc 'Create a new Area'
        params do
          requires :area, type: Hash do
            requires :thana_id, type: Integer
            requires :name, type: String
            requires :bn_name, type: String
            optional :home_delivery, type: Boolean
          end
        end

        post do
          area = Area.new(params[:area])
          area if area.save!
        rescue StandardError => error
          error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # UPDATE ************************************************
        desc 'Update a Area'

        route_param :id do
          put do
            area = Area.find(params[:id])
            area if area.update!(params[:area])
          rescue StandardError => error
            error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        # DELETE ************************************************
        desc 'Delete a Area'

        route_param :id do
          delete do
            Area.find(params[:id]).update!(is_deleted: true)
            respond_with_json("Successfully deleted Area with id #{params[:id]}", HTTP_CODE[:OK])
          rescue StandardError => error
            error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
