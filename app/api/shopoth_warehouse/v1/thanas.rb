module ShopothWarehouse
  module V1
    class Thanas < ShopothWarehouse::Base

      resource :thanas do

        # INDEX *************************************************
        desc 'Get all Thanas.'
        params do
          use :pagination, per_page: 50
        end
        get do
          # TODO: Need to Optimize Query
          response = paginate(Kaminari.paginate_array(ShopothWarehouse::V1::Entities::Thanas.represent(Thana.all)))
          success_response_with_json('Successfully fetched thanas.', HTTP_CODE[:OK],
                                     response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch thanas due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch thanas.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        desc 'Get all thana based on distributor_id.'
        params do
          requires :distributor_id, type: Integer
          optional :home_delivery, type: Boolean
        end
        get '/search' do
          thanas = Thana.where(distributor_id: params[:distributor_id])
          success_response_with_json('Successfully fetched thanas.', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::Thanas.represent(thanas))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch thanas due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch thanas.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        desc 'Get a specific Thana details.'
        get ':id' do
          thana = Thana.find_by(id: params[:id])
          unless thana
            error!(failure_response_with_json('Unable to find thana.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          success_response_with_json('Successfully fetched thana details.', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::Thanas.represent(thana))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch thana details due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch thana details.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        # CREATE ************************************************
        desc 'Create a new Thana.'
        params do
          requires :thana, type: Hash do
            requires :district_id, type: Integer
            requires :name, type: String
            requires :bn_name, type: String
            optional :home_delivery, type: Boolean
          end
        end

        post do
          district = District.find_by(id: params[:thana][:district_id])
          unless district
            error!(failure_response_with_json('Unable to find district.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          thana = Thana.create!(
            district: district,
            name: params[:thana][:name],
            bn_name: params[:thana][:bn_name],
            home_delivery: params[:thana][:home_delivery],
          )
          success_response_with_json('Successfully created thana.', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::Thanas.represent(thana))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create thana due to: #{error.message}"
          error!(failure_response_with_json('Unable to create thana.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        # UPDATE ************************************************
        desc 'Update a Thana.'
        put ':id' do
          thana = Thana.find_by(id: params[:id])
          unless thana
            error!(failure_response_with_json('Unable to find thana.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          district = if params[:thana][:district_id].present?
                       district = District.find_by(id: params[:thana][:district_id])
                       unless district
                         error!(failure_response_with_json('Unable to find district.', HTTP_CODE[:NOT_FOUND]),
                                HTTP_CODE[:OK])
                       end
                       district
                     else
                       thana&.district
                     end

          name = params[:thana][:name].present? ? params[:thana][:name] : thana.name
          bn_name = params[:thana][:bn_name].present? ? params[:thana][:bn_name] : thana.bn_name
          home_delivery = params[:thana][:home_delivery].to_s.present? ? params[:thana][:home_delivery] : thana.home_delivery
          thana.update!(district: district, name: name, bn_name: bn_name, home_delivery: home_delivery)

          success_response_with_json('Successfully updated thana.', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::Thanas.represent(thana))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to update thana due to: #{error.message}"
          error!(failure_response_with_json('Unable to update thana.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        # DELETE ************************************************
        desc 'Delete a Thana.'
        delete ':id' do
          thana = Thana.find_by(id: params[:id])
          unless thana
            error!(failure_response_with_json('Unable to find thana.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          if thana.areas.count.positive? || thana.addresses.count.positive?
            error!(failure_response_with_json("Can't delete thana. It has associated areas or addresses.",
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          thana.update!(is_deleted: true)
          success_response_with_json("Successfully deleted Thana with id #{params[:id]}", HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to delete thana due to: #{error.message}"
          error!(failure_response_with_json('Unable to delete thana.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end
      end
    end
  end
end
