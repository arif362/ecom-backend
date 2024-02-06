module ShopothWarehouse
  module V1
    class ProductFeatures < ShopothWarehouse::Base
      resource :product_features do
        # DELETE ************************************************
        desc 'Delete a product features.'
        params do
          requires :product_id, type: Integer
        end
        delete ':id' do
          unless check_wh_warehouse
            error!(respond_with_json('Only central warehouse can delete product features.',
                                     HTTP_CODE[:FORBIDDEN]), HTTP_CODE[:FORBIDDEN])
          end

          product = Product.find_by(id: params[:product_id])
          unless product
            error!(respond_with_json('Unable to find product.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          product_feature = product.product_features.find_by(id: params[:id])
          unless product_feature
            error!(respond_with_json('Unable to find product feature.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          product_feature.destroy!
          respond_with_json('Successfully deleted product feature.', HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to delete product feature due to: #{error.message}"
          error!(respond_with_json('Unable to delete product feature.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
