module ShopothWarehouse
  module V1
    class Addresses < ShopothWarehouse::Base

      resource :addresses do

        # GET /addresses/
        desc 'Get all addresses'
        get do
          Address.where(is_deleted: false)
        end

        params do
          requires :address, type: Hash do
            requires :district_id, type: Integer
            requires :thana_id, type: Integer
            requires :area_id, type: Integer
            requires :address_line, type: String
            requires :bn_address_line, type: String
            optional :name, type: String
            optional :bn_name, type: String
            optional :zip_code, type: String
            optional :phone, type: String
            optional :bn_phone, type: String
            optional :alternative_phone, type: String
            optional :bn_alternative_phone, type: String
            optional :default_address, type: String
          end
        end

        # POST /addresses/
        desc 'Create a new address'
        post do
          address = Address.new(params[:address])
          address.default_address = true if
            params[:default_address].to_s.downcase == "true"
          if @current_user
            address.user = @current_user
          elsif user = User.find_by(id: params[:user_id])
            address.user = user
          end
          address if address.save!
        rescue => ex
          error! respond_with_json('Unable to create Address. error: #{ex}', HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # PUT /address/:id
        desc 'Update a address'
        route_param :id do
          put do
            address = Address.find(params[:id])
            address if address.update!(params)
          rescue => ex
            error! respond_with_json('Unable to update Address. error: #{ex}', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        # DELETE /addresses/:id/
        desc 'Delete a address'
        route_param :id do
          delete do
            Address.find(params[:id]).update!(is_deleted: true)
            respond_with_json("Successfully deleted Address with id #{params[:id]}", HTTP_CODE[:OK])
          rescue => ex
            error! respond_with_json('Unable to delete Address. error: #{ex}', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
