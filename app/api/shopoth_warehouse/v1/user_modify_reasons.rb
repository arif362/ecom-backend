# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class UserModifyReasons < ShopothWarehouse::Base
      resource :modify_reasons do
        desc 'Reasons List'
        params do
          use :pagination, per_page: 50
        end
        get do
          user_modify_reasons = UserModifyReason.all
          success_response_with_json('Successfully fetched reason list', HTTP_CODE[:OK],
                                     paginate(Kaminari.
                                       paginate_array(ShopothWarehouse::V1::Entities::UserModifyReasons.
                                         represent(user_modify_reasons))))
        rescue StandardError => error
          Rails.logger.info "Unable to fetch due to, #{error.message}"
          error!(failure_response_with_json('Failed to fetch', HTTP_CODE[:UNPROCESSABLE_ENTITY], []),
                 HTTP_CODE[:OK])
        end

        desc 'Create an reason.'
        params do
          requires :title, type: String
          requires :title_bn, type: String
          requires :reason_type, type: String
        end
        post do
          user_modify_reason = UserModifyReason.find_by(title: params[:title])
          unless user_modify_reason.blank?
            error!(failure_response_with_json('Reason already exist', HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:OK])
          end

          UserModifyReason.create!(title: params[:title], title_bn: params[:title_bn], reason_type: params[:reason_type])
          success_response_with_json('Successfully created reason.', HTTP_CODE[:OK], true)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create reason due to: #{error.message}"
          error!(failure_response_with_json('Unable to create reason.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        route_param :id do
          desc 'Reason details.'
          get do
            user_modify_reason = UserModifyReason.find_by(id: params[:id])
            unless user_modify_reason
              error!(failure_response_with_json('Reason not found.',
                                                HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end

            success_response_with_json('Successfully fetched reason details.', HTTP_CODE[:OK],
                                       ShopothWarehouse::V1::Entities::UserModifyReasons.
                                         represent(user_modify_reason))
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to fetch reason details due to: #{error.message}"
            error!(failure_response_with_json('Unable to fetch reason details.',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          desc 'Update an reason.'
          params do
            requires :id, type: Integer
            optional :title, type: String
            optional :title_bn, type: String
          end
          put do
            user_modify_reason = UserModifyReason.find_by(id: params[:id])
            unless user_modify_reason
              error!(failure_response_with_json('Reason not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end
            user_modify_reason.update!(title: params[:title], title_bn: params[:title_bn])

            success_response_with_json('Successfully updated reason.', HTTP_CODE[:OK],true)
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to update reason due to: #{error.message}"
            error!(failure_response_with_json('Unable to update reason.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:OK])
          end

          desc 'Delete reason'
          delete do
            user_modify_reason = UserModifyReason.find_by(id: params[:id])
            unless user_modify_reason
              error!(failure_response_with_json('Reason not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end

            user_modify_reason.delete
            success_response_with_json('Successfully deleted', HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to delete reason due to: #{error.message}"
            error!(failure_response_with_json('Unable to delete reason.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:OK])
          end
        end
      end
    end
  end
end
