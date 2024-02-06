module Ecommerce
  module V1
    class Partners < Ecommerce::Base
      resource :partner do
        # CREATE REVIEW FOR A STORE BY A USER
        desc 'Create review for store by user.'
        params do
          requires :partner_id, type: Integer
          requires :customer_order_id, type: Integer
          requires :title, type: String
          optional :description, type: String
          requires :rating, type: Integer
          optional :images_file
          optional :is_recommended, type: Boolean
        end

        post 'review' do
          unless params[:rating].between?(0, 5)
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.rating_range_not_satisfied'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          store = Partner.active.find_by(id: params[:partner_id])
          unless store
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.store_not_found'),
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          customer_order = store.customer_orders.find_by(id: params[:customer_order_id])
          if customer_order.blank? || customer_order.customer != @current_user
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.customer_order_record_not_found'),
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          unless customer_order.status.completed? || customer_order.status.partially_returned? || customer_order.status.returned_from_partner?
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.customer_order_not_completed'),
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          previous_review = store.reviews.find_by(customer_order: customer_order)
          if previous_review.present?
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.customer_order_review_present'),
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          review = @current_user.reviews.create!(
            title: params[:title],
            description: params[:description],
            rating: params[:rating],
            reviewable: store,
            images_file: params[:images_file],
            is_recommended: params[:is_recommended].present?,
            customer_order: customer_order,
          )

          formatted_review = Ecommerce::V1::Entities::Reviews.represent review
          success_response_with_json(I18n.t('Ecom.success.messages.store_review_creation_successful'),
                                     HTTP_CODE[:CREATED], formatted_review)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create a review due to: #{error.message}"
          error!(failure_response_with_json("#{I18n.t('Ecom.errors.messages.unable_to_process_request')} #{error}",
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Favourite store creation.'
        params do
          requires :partner_id, type: Integer
        end
        post 'make_favorite' do
          unless @current_user.favorite_stores.count < 4
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.store_favorite_limit_exceed'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          partner = Partner.active.find_by(id: params[:partner_id])
          unless partner
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.partner_not_found'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          if @current_user.favorite_stores.pluck(:partner_id).include?(partner.id)
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.store_already_in_favourite_list'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          store = @current_user.favorite_stores.find_or_create_by(partner_id: params[:partner_id])
          response = Ecommerce::V1::Entities::FavoriteStores.represent(store, user: @current_user)
          success_response_with_json(I18n.t('Ecom.success.messages.store_favorite_successful'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to make store favourite due to: #{error.message}"
          error!(failure_response_with_json("#{I18n.t('Ecom.errors.messages.unable_to_process_request')} #{error}",
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'unfavourite store'
        params do
          requires :partner_id, type: Integer
        end
        delete 'unfavorite' do
          store = @current_user.favorite_stores&.find_by(partner_id: params[:partner_id])

          if store.present?
            store.delete
            success_response_with_json(I18n.t('Ecom.success.messages.store_unfavorite_successful'), HTTP_CODE[:OK], store)
          else
            failure_response_with_json(I18n.t('Ecom.errors.messages.store_not_favorited'), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        rescue StandardError => error
          failure_response_with_json("#{I18n.t('Ecom.errors.messages.unable_to_process_request')} #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'favourite store list.'
        params do
          optional :filter_by_fc, type: Boolean
          optional :warehouse_id, type: Integer
          optional :district_id, type: Integer
        end
        get 'favourite_list' do
          stores = @current_user.favorite_stores.joins(partner: :address).
                   where(partners: { status: :active, is_b2b: false })
          stores = stores.where('addresses.district_id = ?', params[:district_id]) if params[:district_id]
          if params[:filter_by_fc]
            warehouse = Warehouse.find_by(id: params[:warehouse_id])
            stores = stores.where('addresses.district_id IN (?)', warehouse&.districts&.ids)
          end
          formatted_stores = Ecommerce::V1::Entities::FavoriteStores.represent(stores, user: @current_user)
          success_response_with_json(I18n.t('Ecom.success.messages.favorite_partner_fetch_successful'),
                                     HTTP_CODE[:OK], formatted_stores)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch favourite store list due to: #{error.message}"
          error!(failure_response_with_json("#{I18n.t('Ecom.errors.messages.unable_to_process_request')} #{error.message}",
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Store/Partner details.'
        route_setting :authentication, optional: true
        get ':id' do
          partner = Partner.includes(:address, :reviews).active.find_by(slug: params[:id])
          unless partner
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.store_not_found'),
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          partner_info = Ecommerce::V1::Entities::PartnerDetails.represent(partner, user: @current_user)
          success_response_with_json(I18n.t('Ecom.success.messages.store_details_fetch_successful'),
                                     HTTP_CODE[:OK], partner_info)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch partner details due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.store_details_fetch_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
