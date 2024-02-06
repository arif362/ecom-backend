# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class PromoBanners < ShopothWarehouse::Base
      resource :promo_banners do
        desc 'Get all promo banner.'
        params do
          use :pagination, per_page: 50
        end
        get do
          # TODO: Need to Optimize Query
          data = ShopothWarehouse::V1::Entities::PromoBanners.represent(
            paginate(Kaminari.paginate_array(PromoBanner.all)),
          )
          success_response_with_json('Successfully fetched promo banner.', HTTP_CODE[:OK], data)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch promo banner due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch promo banner.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Get a specific promo banner.'
        get ':id' do
          promo_banner = PromoBanner.find_by(id: params[:id])
          unless promo_banner
            error!(failure_response_with_json('Unable to find promo banner.',
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          data = ShopothWarehouse::V1::Entities::PromoBanners.represent(promo_banner)
          success_response_with_json('Successfully fetched promo banner.', HTTP_CODE[:OK], data)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch promo banner due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch promo banner.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Create a promo banner.'
        params do
          requires :title, type: String
          requires :layout, type: Integer
          optional :is_visible, type: Boolean
          requires :banner_images_attributes, type: Array do
            requires :image_title, type: String
            requires :description, type: String
            requires :image_type, type: String
            requires :redirect_url, type: String
            requires :image_file, type: File
          end
        end
        post do
          unless PromoBanner.valid_images?(params[:banner_images_attributes])
            error!(failure_response_with_json('Please give valid images.',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          promo_banner = PromoBanner.create!(params)
          data = ShopothWarehouse::V1::Entities::PromoBanners.represent(promo_banner)
          success_response_with_json('Successfully created promo banner.', HTTP_CODE[:OK], data)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create promo banner due to: #{error.message}"
          error!(failure_response_with_json("Unable to create promo banner. error: #{error.message}",
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Update a promo banner.'
        put ':id' do
          promo_banner = PromoBanner.find_by(id: params[:id])
          unless promo_banner
            error!(failure_response_with_json('Unable to find promo banner.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          promo_banner.update!(params)
          data = ShopothWarehouse::V1::Entities::PromoBanners.represent(promo_banner)
          success_response_with_json('Successfully updated promo banner.', HTTP_CODE[:OK], data)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to update promo banner due to: #{error.message}"
          error!(failure_response_with_json("Unable to update promo banner. error: #{error.message}",
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Delete a promo banner.'
        delete ':id' do
          promo_banner = PromoBanner.find_by(id: params[:id])
          unless promo_banner
            error!(failure_response_with_json('Unable to find promo banner.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          promo_banner.destroy!
          success_response_with_json('Successfully deleted promo banner.', HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to delete promo banner due to: #{error.message}"
          error!(failure_response_with_json('Unable to delete promo banner.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
