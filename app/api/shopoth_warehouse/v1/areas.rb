module ShopothWarehouse
  module V1
    class Areas < ShopothWarehouse::Base
      resource :areas do
        # INDEX *************************************************
        desc 'Get all Areas.'
        params do
          use :pagination, per_page: 50
        end
        get do
          # TODO: Need to Optimize Query
          areas = paginate(Kaminari.paginate_array(ShopothWarehouse::V1::Entities::Areas.represent(Area.all)))
          success_response_with_json('Successfully fetched areas.', HTTP_CODE[:OK],
                                     areas)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch areas due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch areas.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        desc 'Get all Area based on thana_id.'
        params do
          requires :thana_id, type: Integer
          optional :home_delivery, type: Boolean
        end
        get '/search' do
          areas = if params[:home_delivery]
                    Area.home_delivery_by_thana(params[:thana_id])
                  else
                    Area.where(thana_id: params[:thana_id])
                  end
          success_response_with_json('Successfully fetched areas.', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::Areas.represent(areas))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch areas due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch areas.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        desc 'Get a specific Area details.'
        get ':id' do
          area = Area.find_by(id: params[:id])
          unless area
            error!(failure_response_with_json('Unable to find area.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          success_response_with_json('Successfully fetched area details.', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::Areas.represent(area))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch area details due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch area details.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        # CREATE ************************************************
        desc 'Create a new Area.'
        params do
          requires :area, type: Hash do
            requires :thana_id, type: Integer
            requires :name, type: String
            requires :bn_name, type: String
            optional :home_delivery, type: Boolean
          end
        end
        post do
          thana = Thana.find_by(id: params[:area][:thana_id])
          unless thana
            error!(failure_response_with_json('Unable to find thana.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          area = Area.create!(
            thana: thana,
            name: params[:area][:name],
            bn_name: params[:area][:bn_name],
            home_delivery: params[:area][:home_delivery],
          )
          success_response_with_json('Successfully created area.', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::Areas.represent(area))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create area due to: #{error.message}"
          error!(failure_response_with_json('Unable to create area.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        # UPDATE ************************************************
        desc 'Update a Area.'
        put ':id' do
          area = Area.find_by(id: params[:id])
          unless area
            error!(failure_response_with_json('Unable to find area.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          thana = if params[:area][:thana_id].present?
                    thana = Thana.find_by(id: params[:area][:thana_id])
                    unless thana
                      error!(failure_response_with_json('Unable to find thana.', HTTP_CODE[:NOT_FOUND]),
                             HTTP_CODE[:OK])
                    end
                    thana
                  else
                    area&.thana
                  end

          name = params[:area][:name].present? ? params[:area][:name] : area.name
          bn_name = params[:area][:bn_name].present? ? params[:area][:bn_name] : area.bn_name
          home_delivery = params[:area][:home_delivery].to_s.present? ? params[:area][:home_delivery] : area.home_delivery
          area.update!(thana: thana, name: name, bn_name: bn_name, home_delivery: home_delivery)

          success_response_with_json('Successfully updated area.', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::Areas.represent(area))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to update area due to: #{error.message}"
          error!(failure_response_with_json('Unable to update area.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        # DELETE ************************************************
        desc 'Delete a Area.'
        delete ':id' do
          area = Area.find_by(id: params[:id])
          unless area
            error!(failure_response_with_json('Unable to find area.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          if area.addresses.count.positive?
            error!(failure_response_with_json("Can't delete area. It has associated addresses.",
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          area.update!(is_deleted: true)
          success_response_with_json("Successfully deleted Area with id #{params[:id]}", HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to delete area due to: #{error.message}"
          error!(failure_response_with_json('Unable to delete area.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end
      end
    end
  end
end
