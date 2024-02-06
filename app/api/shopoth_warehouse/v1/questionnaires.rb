module ShopothWarehouse
  module V1
    class Questionnaires < ShopothWarehouse::Base
      INVALID = 'invalid record'.freeze
      UNAVAILABLE_QUES = 'no questions'.freeze
      POSITIVE = []
      NEGATIVE = []

      resource :questionnaires do
        desc 'get a questionnaire by category_id and type'
        params do
          requires :category_id, type: Integer
          requires :questionnaire_type, type: String
        end
        get '/list' do
          category_id = params[:category_id]
          category = Category.find(category_id)
          parent_category_id = category.parent_id.nil? ? category_id : Category.fetch_parent_category(category)
          questionnaires = Questionnaire.where(category_id: parent_category_id,
                                               questionnaire_type: params[:questionnaire_type])
          return questionnaires if questionnaires.present?

          error! respond_with_json("Unable to find questionnaire with id #{params[:category_id]} and type #{params[:questionnaire_type]}",
                                   HTTP_CODE[:NOT_FOUND])
        end

        desc 'Questionnaires for return orders.'
        params do
          optional :category_id, type: Integer
          requires :return_order_id, type: Integer
        end
        get '/returns_questions' do
          return_order = ReturnCustomerOrder.find(params[:return_order_id])
          if return_order&.unpacked?
            category_id = params[:category_id]
            category = Category.find(category_id)
            parent_category_id = category.parent_id.nil? ? category_id : Category.fetch_parent_category(category)
            questionnaires = Questionnaire.where(category_id: parent_category_id, questionnaire_type: 'Return')
          elsif return_order&.packed?
            questionnaires = Questionnaire.where(category_id: nil, questionnaire_type: 'Return')
          end

          return questionnaires if questionnaires.present?
        rescue StandardError => error
          error!(respond_with_json("Unable to fetch questionnaire due to #{error.message}",
                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end

        desc 'create a questionnaire'
        params do
          requires :question, type: String
          requires :category_id, type: Integer
          requires :questionnaire_type, type: String
        end

        post do
          questionnaire = Questionnaire.new(params)
          questionnaire if questionnaire.save!
        rescue StandardError => e
          error! respond_with_json("Unable to create Questionnaire due to #{e.message}.",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'return a questionnaire'
        params do
          requires :id, type: Integer, desc: 'questionnaire'
        end

        route_param :id do
          get do
            questionnaire = Questionnaire.find(params[:id])
            return questionnaire if questionnaire

          rescue StandardError => e
            error! respond_with_json("Unable to find questionnaire with id #{params[:id]} due to #{e.message}",
                                     HTTP_CODE[:NOT_FOUND])
          end
        end

        desc 'update a specific questionnaire'
        route_param :id do
          put do
            questionnaire = Questionnaire.find(id: params[:id])
            updated_questionnaire = questionnaire.update!(params) if questionnaire.present?
            return updated_questionnaire if questionnaire

          rescue StandardError => e
            error! respond_with_json("Unable to update Questionnaire due to #{e.message}.",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'delete a specific questionnaire'
        params do
          requires :id, type: String, desc: 'questionnaire'
        end

        delete ':id' do
          questionnaire = Questionnaire.find(id: params[:id])
          questionnaire.destroy if questionnaire
          return questionnaire if questionnaire

        rescue StandardError => e
          error! respond_with_json("Unable to delete questionnaire with id #{params[:id]} due to #{e.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'create failed_qc'
        params do
          optional :question_list, type: Array
          given :question_list do
            requires :answer_list, type: Array
          end
          optional :quantity, type: Integer
          requires :variant_id, type: Integer
          requires :purchase_order_id, type: Integer
        end

        post '/create_failed_qc' do
          question_list = params[:question_list]
          wh_order = WhPurchaseOrder.find_by(id: purchase_order_id)
          dh_order = DhPurchaseOrder.find_by(id: purchase_order_id)
          order = wh_order || dh_order
          if params[:quantity].present?
            original_quantity = wh_order.present? ? wh_order.quantity : dh_order.quantity
            if original_quantity != quantity
              remaining_quantity = quantity - original_quantity
              FailedQc.create({ variant_id: variant_id,
                                quantity: remaining_quantity,
                                failable: order })
            end
          elsif question_list.present?
            params[:answer_list].select.with_index do |answer, index|
              if answer == 'yes'
                POSITIVE << question_list[index]
              else
                NEGATIVE << question_list[index]
                FailedQc.create!({ variant_id: variant_id,
                                   failable: order,
                                   questions: NEGATIVE.flatten.compact })
              end
            end
          end
        rescue StandardError => e
          error! respond_with_json("Unable to create FailedQc due to #{e.message}.", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
