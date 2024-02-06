# frozen_string_literal: true

module ThirdPartyService
  module V1
    class RetailerAssistants < ThirdPartyService::Base
      resource 'retailer_assistants' do
        desc 'Create a retailer assistant'
        params do
          requires :name, type: String
          requires :phone, type: String
          optional :email, type: String
          requires :password, type: String
          requires :password_confirmation, type: String
          requires :category, type: String
          optional :father_name, type: String
          optional :experience, type: String
          optional :education, type: String
          optional :date_of_birth, type: DateTime, coerce_with: DateTime.method(:iso8601)
          optional :nid, type: String
          optional :tech_skill, type: String
          requires :warehouse_id, type: Integer
        end

        post do
          retailer_assistant = RetailerAssistant.find_by(email: params[:email])
          if retailer_assistant
            error!(respond_with_json('Can not create due to Validation failed: Email has already been taken', HTTP_CODE[:CONFLICT]),
                   HTTP_CODE[:CONFLICT])
          end

          retailer_assistant = RetailerAssistant.find_by(phone: params[:phone])
          if retailer_assistant
            error!(respond_with_json('Can not create due to Validation failed: Phone number has already been taken', HTTP_CODE[:CONFLICT]),
                   HTTP_CODE[:CONFLICT])
          end

          RetailerAssistant.create!(params)
          present :success, true
          present :message, 'Successfully created'
          present :status_code, 201
        rescue StandardError => e
          error!(respond_with_json("Can not create due to #{e}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        params do
          optional :ra_phone, type: String
          requires :start_date_time, type: DateTime
          requires :end_date_time, type: DateTime
        end
        desc 'Customer list of RA'
        get :customers do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_day
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day

          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= 1.month
            return failure_response_with_json("The selected date range (start_date: #{start_date_time} and end_date: #{end_date_time}) is not valid! Please select a range within 1 months.", HTTP_CODE[:NOT_ACCEPTABLE])
          end

          users = User.with_retailer_assistant.where('users.created_at BETWEEN ? AND ? AND registerable_type = ?', start_date_time, end_date_time, 'RetailerAssistant')

          if params[:ra_phone].present?
            retailer_assistant = RetailerAssistant.find_by(phone: params[:ra_phone])
            unless retailer_assistant
              error!(failure_response_with_json('Retailer assistant not found', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
            users = users.where(registerable: retailer_assistant)
          end
          success_response_with_json(
            'successfully fetch',
            HTTP_CODE[:OK],
            ThirdPartyService::V1::Entities::User.represent(users),
          )
        rescue StandardError => e
          error!(respond_with_json('Internal server error', HTTP_CODE[:INTERNAL_SERVER_ERROR]),
                 HTTP_CODE[:INTERNAL_SERVER_ERROR])
        end
      end
    end
  end
end
