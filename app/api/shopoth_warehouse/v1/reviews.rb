# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class Reviews < ShopothWarehouse::Base
      resource :reviews do
        desc 'Get all reviews and filer by product_id for Admin.'
        params do
          optional :product_id, type: Integer
          optional :reviewable_type, type: String
          use :pagination, per_page: 50
        end
        get do
          reviews = if params[:reviewable_type].present?
                      params[:reviewable_type] == 'Partner' ? Review.partner_reviews : Review.variant_reviews
                    else
                      Review.all
                    end

          if params[:product_id].present?
            product = Product.find_by(id: params[:product_id])
            unless product
              error!(failure_response_with_json('Unable to find product.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:OK])
            end

            reviews = reviews.where(variant_id: product.variants.ids)
            unless reviews.present?
              error!(failure_response_with_json('Unable to fetch reviews.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:OK])
            end
          end
          # TODO: Need to Optimize Query
          response = ShopothWarehouse::V1::Entities::Reviews.represent(paginate(Kaminari.paginate_array(reviews)))
          success_response_with_json("Successfully fetched product's reviews.", HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch reviews due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch reviews.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        desc 'Get a specific review details.'
        get ':id' do
          review = Review.find_by(id: params[:id])
          unless review
            error!(failure_response_with_json('Unable to find review.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          response = ShopothWarehouse::V1::Entities::Reviews.represent(review)
          success_response_with_json('Successfully fetched product review.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch reviews due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch review.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        desc 'Approve a review.'
        put 'approve/:id' do
          review = Review.find_by(id: params[:id])
          unless review
            return { success: false, status: HTTP_CODE[:NOT_FOUND], message: 'Unable to find review.', data: {} }
          end

          review.update!(is_approved: true)
          return { success: true, status: HTTP_CODE[:OK], message: 'Successfully approved review.', data: {} }
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to approve review due to: #{error.message}"
          return { success: false, status: HTTP_CODE[:UNPROCESSABLE_ENTITY], message: 'Unable to approve review.', data: {} }
        end
      end
    end
  end
end
