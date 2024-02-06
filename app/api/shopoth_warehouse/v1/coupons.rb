module ShopothWarehouse
  module V1
    class Coupons < ShopothWarehouse::Base
      resource :coupons do
        desc 'check the coupon code'
        params do
          requires :code, type: String, allow_blank: false
        end
        get 'check' do
          coupon = Coupon.find_by(code: params[:code])
          if coupon
            status :unprocessable_entity
            {
              is_exist: true,
              message: 'already exists',
            }
          else
            status :ok
            {
              is_exist: false,
              message: 'unique coupon',
            }
          end
        end

        desc 'get all first registration & multiple use coupon'
        params do
          use :pagination, per_page: 25
        end
        get do
          coupons = Coupon.fetch_coupon(%w(first_registration multi_user))
          # TODO: Need to Optimize Query
          success_response_with_json('Successfully fetched first_registration and multi_user coupons', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::Coupons.represent(
                                       paginate(Kaminari.paginate_array(coupons)),
                                     ))
        rescue StandardError => error
          Rails.logger.info "Unable to fetch due to, #{error.message}"
          error!(failure_response_with_json("Unable to fetch due to, #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                 HTTP_CODE[:OK])
        end

        desc ' Create a coupon'
        params do
          requires :code, type: String
          requires :discount_amount, type: Integer
          requires :start_at, type: DateTime
          requires :end_at, type: DateTime
          requires :coupon_type, type: String, values: %w(first_registration multi_user)
          requires :discount_type, type: String
          requires :is_visible, type: Boolean
          optional :max_limit, type: BigDecimal
          optional :is_active, type: Boolean
          optional :max_user_limit, type: Integer
          optional :used_count, type: Integer
          optional :skus, type: String
          optional :sku_inclusion_type, type: String, values: %w(not_applicable included excluded)
          optional :phone_numbers, type: String
          requires :coupon_category_attributes, type: Hash do
            optional :category_inclusion_type, type: String, values: %w(included excluded)
            optional :category_ids, type: Array
          end
        end
        post do
          unless check_wh_warehouse
            error!(failure_response_with_json('You are not eligible to create coupon',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
          coupon_types_value = %w(first_registration multi_user)
          unless coupon_types_value.include?(params[:coupon_type])
            error!(failure_response_with_json('Select a valid coupon type',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
          if params[:coupon_type] == 'first_registration' && !Coupon.first_registration.active.blank?
            error!(failure_response_with_json('Already one active first order coupon exists',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
          params[:code] = params[:code].upcase

          if params[:sku_inclusion_type].present?
            if params[:coupon_type] != 'multi_user'
              error!(failure_response_with_json('Only multi-user coupon can have sku',
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
            if params[:skus].blank? && (params[:sku_inclusion_type] != 'not_applicable')
              error!(failure_response_with_json('Must provide sku to create coupon with sku',
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
          end

          if params[:coupon_category_attributes][:category_inclusion_type].present?
            if params[:coupon_type] != 'multi_user'
              error!(failure_response_with_json('Only multi-user coupon can have category',
                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
            if params[:coupon_category_attributes][:category_ids].blank?
              error!(failure_response_with_json('Must provide category IDs to create coupon with category',
                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
            Coupon.create!(params.merge!(created_by_id: @current_staff.id))
          else
            if params[:coupon_category_attributes][:category_ids].present?
              error!(failure_response_with_json('Must provide category inclusion type to create coupon with category',
                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
            # create coupon without category
            Coupon.create!(params.except!('coupon_category_attributes').merge!(created_by_id: @current_staff.id))
          end
          success_response_with_json('Successfully created coupon', HTTP_CODE[:OK], true)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create coupon due to: #{error.message}"
          error!(failure_response_with_json("Unable to create coupon due to: #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        route_param :id do
          desc 'get a coupon'
          get do
            coupon = Coupon.fetch_coupon(%w(first_registration multi_user)).find_by(id: params[:id])
            unless coupon
              error!(failure_response_with_json('Coupon not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end
            success_response_with_json('Successfully fetched coupon', HTTP_CODE[:OK],
                                       ShopothWarehouse::V1::Entities::Coupons.represent(coupon))
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to fetched coupon due to: #{error.message}"
            error!(failure_response_with_json('Unable to fetched coupon.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:OK])
          end

          desc 'delete a coupon'
          delete do
            coupon = Coupon.fetch_coupon(%w(first_registration multi_user)).find_by(id: params[:id])
            coupon.destroy
            success_response_with_json('Successfully deleted', HTTP_CODE[:OK], true)
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to delete coupon due to: #{error.message}"
            error!(failure_response_with_json("Unable to delete coupon due to: #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:OK])
          end

          desc 'update a coupon'
          params do
            requires :discount_amount, type: Integer, allow_blank: false
            requires :coupon_type, type: String, values: %w(first_registration multi_user)
            optional :discount_type, type: String
            optional :max_limit, type: BigDecimal
            optional :start_at, type: DateTime
            optional :end_at, type: DateTime
            optional :is_active, type: Boolean
            optional :max_user_limit, type: Integer
            optional :used_count, type: Integer
            optional :skus, type: String
            optional :sku_inclusion_type, type: String, values: %w(not_applicable included excluded)
            optional :phone_numbers, type: String
            requires :coupon_category_attributes, type: Hash do
              optional :category_inclusion_type, type: String, values: %w(included excluded)
              optional :category_ids, type: Array
            end
          end

          put do
            coupon = Coupon.find_by(id: params[:id])
            if params[:is_active] == true && coupon.first_registration? && Coupon.first_registration.active.where.not(id: coupon.id).present?
              error!(failure_response_with_json('Already one active coupon exists',
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
            if params[:sku_inclusion_type].present?
              if params[:coupon_type] != 'multi_user'
                error!(failure_response_with_json('Only multi-user coupon can have sku',
                                                  HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
              end
              if params[:skus].blank? && (params[:sku_inclusion_type] != 'not_applicable')
                error!(failure_response_with_json('Must provide sku to create coupon with sku',
                                                  HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
              end
            end
            # category is updated
            ActiveRecord::Base.transaction do
              if params[:coupon_category_attributes][:category_inclusion_type].present?
                if params[:coupon_type] != 'multi_user'
                  error!(failure_response_with_json('Only multi-user coupon can have category',
                    HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
                end
                if params[:coupon_category_attributes][:category_ids].blank?
                  error!(failure_response_with_json('Must provide category IDs to create coupon with category',
                    HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
                end
                coupon.update!(params.except('coupon_category_attributes'))
                coupon.coupon_category&.destroy
                coupon.create_coupon_category(category_inclusion_type: params[:coupon_category_attributes][:category_inclusion_type],
                                              category_ids: params[:coupon_category_attributes][:category_ids])
              else
                coupon.update!(params)
                coupon.coupon_category&.destroy
              end
            end
            success_response_with_json('Successfully updated', HTTP_CODE[:OK], true)
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to update coupon due to: #{error.message}"
            error!(failure_response_with_json("Unable to update coupon due to: #{error.message}",
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
        end
      end
    end
  end
end
