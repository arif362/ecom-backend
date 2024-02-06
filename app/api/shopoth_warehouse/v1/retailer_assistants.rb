module ShopothWarehouse
  module V1
    class RetailerAssistants < ShopothWarehouse::Base
      resource :retailer_assistants do
        desc 'Get all retailer assistants list'
        params do
          use :pagination, per_page: 50
        end
        get do
          list = check_dh_warehouse ? @current_staff.warehouse.retailer_assistants : RetailerAssistant.all
          list = list.where(distributor_id: params[:distributor_id]) if params[:distributor_id].present?
          # TODO: Need to Optimize Query
          list = paginate(Kaminari.paginate_array(list.order(created_at: :desc)))
          present list, with: ShopothWarehouse::V1::Entities::RetailerAssistants
        rescue StandardError => e
          error!(respond_with_json("Can not fetch due to #{e}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Create a retailer assistant'
        params do
          requires :name, type: String
          requires :phone, type: String
          optional :email, type: String
          requires :password, type: String
          requires :password_confirmation, type: String
          requires :category, type: String
          requires :distributor_id, type: Integer
          optional :father_name, type: String
          optional :experience, type: String
          optional :education, type: String
          optional :date_of_birth, type: DateTime, coerce_with: DateTime.method(:iso8601)
          optional :nid, type: String
          optional :tech_skill, type: String
          requires :address_attributes, type: Hash do
            requires :area_id, type: Integer
            requires :address_line, type: String
          end
        end
        post do
          distributor = @current_staff.warehouse.distributors.find_by(id: params[:distributor_id])
          unless distributor.present?
            error!(failure_response_with_json('Unable to find distributor',
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end
          retailer_assistant = distributor.retailer_assistants.new(params.except(:address_attributes).
            merge!(warehouse: @current_staff.warehouse, created_by_id: @current_staff.id))
          retailer_assistant.save!
          retailer_assistant.create_retailer_address(params[:address_attributes])
          success_response_with_json('Successfully created', HTTP_CODE[:OK], true)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create retailer assistant due to: #{error.message}"
          error!(failure_response_with_json('Unable to create retailer assistant',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Update a retailer assistant'
        route_param :id do
          params do
            optional :distributor_id, type: Integer
            optional :name, type: String
            optional :phone, type: String
            optional :email, type: String
            optional :category, type: String
            optional :bn_name, type: String
            optional :father_name, type: String
            optional :experience, type: String
            optional :education, type: String
            optional :nid, type: String
            optional :date_of_birth, type: DateTime, coerce_with: DateTime.method(:iso8601)
            optional :tech_skill, type: String
            optional :address_attributes, type: Hash do
              optional :area_id, type: Integer
              optional :address_line, type: String
            end
          end
          put do
            if params[:distributor_id].present?
              distributor = @current_staff.warehouse.distributors.find_by(id: params[:distributor_id])
              unless distributor.present?
                error!(failure_response_with_json('Not found', HTTP_CODE[:NOT_FOUND]),
                       HTTP_CODE[:OK])
              end
            end
            retailer_assistant = @current_staff.warehouse.retailer_assistants.find_by(id: params[:id])
            retailer_assistant.update!(params.except(:address_attributes))
            retailer_assistant.address.update!(params[:address_attributes]) if params[:address_attributes]
            success_response_with_json('Successfully updated', HTTP_CODE[:OK], true)
          rescue StandardError => error
            error!(failure_response_with_json("Can not update due to #{error}",
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
        end

        desc 'RA Categories'
        get '/ra-categories' do
          RetailerAssistant.categories
        end

        desc 'Return a ra'
        route_param :id do
          get do
            retailer_assistant = RetailerAssistant.find_by(id: params[:id])
            unless retailer_assistant.present?
              error!(failure_response_with_json('Not found', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:OK])
            end
            success_response_with_json('Successfully fetched', HTTP_CODE[:OK],
                                       ShopothWarehouse::V1::Entities::RetailerAssistantDetails.represent(retailer_assistant))
          rescue StandardError => e
            error!(respond_with_json("Unable to fetch", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Inactive a ra'
        route_param :id do
          delete do
            retailer_assistant = @current_staff.warehouse.retailer_assistants.active.
                                 find_by(id: params[:id])
            unless retailer_assistant.present?
              error!(respond_with_json('RA not found', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
            retailer_assistant.update!(status: 'inactive')
            respond_with_json('Successfully deleted', HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.info "Unable to delete #{error.message}"
            error!(respond_with_json('Unable to delete', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
