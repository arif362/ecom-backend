module ShopothWarehouse
  module V1
    class Districts < ShopothWarehouse::Base
      resource :districts do
        # INDEX *************************************************
        desc 'Get all Districts.'
        params do
          use :pagination, per_page: 50
          optional :warehouse_id, type: Integer
        end
        get do
          districts = if params[:warehouse_id].present?
                        District.where(warehouse_id: params[:warehouse_id])
                      else
                        District.all
                      end
          # TODO: Need to Optimize Query
          response = paginate(Kaminari.paginate_array(ShopothWarehouse::V1::Entities::Districts.represent(districts)))
          success_response_with_json('Successfully fetched districts.', HTTP_CODE[:OK],
                                     response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch districts due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch districts.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        desc 'Get a specific District details.'
        get ':id' do
          district = District.find_by(id: params[:id])
          unless district
            error!(failure_response_with_json('Unable to find district.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          success_response_with_json('Successfully fetched district details.', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::Districts.represent(district))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch district details due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch district details.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        # CREATE ************************************************
        desc 'Create a new District.'
        params do
          requires :district, type: Hash do
            requires :name, type: String
            requires :bn_name, type: String
          end
        end

        post do
          district = District.create!(
            name: params[:district][:name],
            bn_name: params[:district][:bn_name],
          )
          success_response_with_json('Successfully created district.', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::Districts.represent(district))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create district due to: #{error.message}"
          error!(failure_response_with_json('Unable to create district.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        # UPDATE ************************************************
        desc 'Update a District.'
        put ':id' do
          district = District.find_by(id: params[:id])
          unless district
            error!(failure_response_with_json('Unable to find district.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          name = params[:district][:name].present? ? params[:district][:name] : district.name
          bn_name = params[:district][:bn_name].present? ? params[:district][:bn_name] : district.bn_name
          district.update!(name: name, bn_name: bn_name)
          success_response_with_json('Successfully updated district.', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::Districts.represent(district))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to update district due to: #{error.message}"
          error!(failure_response_with_json('Unable to update district.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        # DELETE ************************************************
        desc 'Delete a District.'
        delete ':id' do
          district = District.find_by(id: params[:id])
          unless district
            error!(failure_response_with_json('Unable to find district.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          if district.thanas.count.positive? || district.addresses.count.positive?
            error!(failure_response_with_json("Can't delete district. It has associated thanas or addresses.",
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          district.update!(is_deleted: true)
          success_response_with_json("Successfully deleted District with id #{params[:id]}", HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to delete district due to: #{error.message}"
          error!(failure_response_with_json('Unable to delete district.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end
      end
    end
  end
end
