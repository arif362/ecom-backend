# frozen_string_literal: true

module Ecommerce
  module V1
    class Reviews < Ecommerce::Base
      resource :reviews do
        # GET ALL REVIEWS FOR USER
        desc 'Get review list.'
        get do
          response = Ecommerce::V1::Entities::Reviews.represent(@current_user.reviews.approved)
          success_response_with_json(I18n.t('Ecom.success.messages.user_reviews_fetch_successful'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch reviews due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.user_reviews_fetch_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        # CREATE REVIEW FOR A PRODUCT BY A USER
        desc 'Create review by a user.'
        params do
          requires :title, type: String
          optional :description, type: String
          requires :rating, type: Integer
          requires :shopoth_line_item_id, type: Integer
          optional :images_file
          optional :is_recommended, type: Boolean
        end

        post do
          unless params[:rating].between?(0, 5)
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.rating_range_not_satisfied'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          line_item = @current_user.shopoth_line_items.find_by(id: params[:shopoth_line_item_id])
          existing_review = @current_user.reviews.find_by(title: params[:title], shopoth_line_item: line_item)
          if existing_review
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.review_already_present'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          completed_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
          completed_status_change = line_item.customer_order&.customer_order_status_changes&.find_by(order_status: completed_status)
          unless line_item.customer_order&.is_customer_paid? && completed_status_change
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.review_restriction'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          review = @current_user.reviews.new(
            title: params[:title],
            description: params[:description],
            rating: params[:rating],
            shopoth_line_item: line_item,
            reviewable: line_item&.variant,
            images_file: params[:images_file],
            is_recommended: params[:is_recommended].present?,
          )
          review.save!

          response = Ecommerce::V1::Entities::Reviews.represent(review)
          success_response_with_json(I18n.t('Ecom.success.messages.review_creation_successful'),
                                     HTTP_CODE[:CREATED], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create a review due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.review_creation_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Update a specific review.'
        params do
          optional :title, type: String
          optional :description, type: String
          optional :rating, type: Integer
          optional :images_file
        end
        put ':id' do
          review = @current_user.reviews.find_by(id: params[:id])
          unless review
            return { success: false, status: HTTP_CODE[:NOT_FOUND], message: 'Unable to find a review.', data: {} }
          end

          review.update!(params)

          present :success, true
          present :status, HTTP_CODE[:OK]
          present :message, 'Successfully updated product review.'
          present :data, review, with: Ecommerce::V1::Entities::Reviews
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to update review due to: #{error.message}"
          return { success: false, status: HTTP_CODE[:UNPROCESSABLE_ENTITY], message: 'Unable to update review.', data: {} }
        end

        # DELETE A REVIEW
        desc 'Delete a specific review.'
        delete ':id' do
          review = @current_user.reviews.find_by(id: params[:id])
          unless review
            return { success: false, status: HTTP_CODE[:NOT_FOUND], message: 'Unable to find a review.', data: {} }
          end

          review.destroy!
          return { success: true, status: HTTP_CODE[:OK], message: 'Successfully deleted review.', data: {} }
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to delete review due to: #{error.message}"
          return { success: false, status: HTTP_CODE[:UNPROCESSABLE_ENTITY], message: 'Unable to delete review.', data: {} }
        end
      end
    end
  end
end
