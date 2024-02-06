# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class PromoCoupons < ShopothWarehouse::Base
      resource :promo_coupons do
        desc 'SKU Search'
        params do
          requires :sku, type: String
        end
        get :search_by_sku do
          variants = Variant.select(:id, :sku).where('LOWER(sku) LIKE :sku', sku: "%#{params[:sku].downcase}%").limit(10)
          success_response_with_json('Successfully Search By SKU.', HTTP_CODE[:OK], variants)
        rescue StandardError => error
          error!(failure_response_with_json("Something went wrong due to #{error.message}.",
                                            HTTP_CODE[:INTERNAL_SERVER_ERROR]), HTTP_CODE[:OK])
        end

        desc 'Search By Title.'
        params do
          requires :type, type: String
          requires :keyword, type: String
        end
        get :search_by_title do
          keyword = params[:keyword].downcase

          case params[:type]
          when 'Brand'
            list = Brand.select(:id, :name).where('LOWER(name) LIKE :keyword OR LOWER(bn_name) LIKE :keyword', keyword: "%#{keyword}%").limit(10)
          when 'Category'
            list = Category.select(:id, :title).where('LOWER(title) LIKE :keyword OR LOWER(bn_title) LIKE :keyword', keyword: "%#{keyword}%").limit(10)
          when 'Warehouse'
            list = Warehouse.select(:id, :name).where("warehouse_type = 'distribution' AND (LOWER(name) LIKE :keyword OR LOWER(bn_name) LIKE :keyword)", keyword: "%#{keyword}%").limit(10)
          else
            error!(failure_response_with_json('Given type is not matched', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:OK])
          end
          success_response_with_json('Successfully Search By Title.', HTTP_CODE[:OK], list)
        rescue StandardError => error
          Rails.logger.error "\n\n#{__FILE__}Something went wrong due to #{error.message}.\n"
          error!(failure_response_with_json('Unable to fetch list.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        desc 'Search By Phone'
        params do
          requires :type, type: String
          requires :phone, type: String
        end
        get :search_by_phone do
          case params[:type]
          when 'User'
            list = User.select(:id, :phone, :full_name).where('LOWER(phone) LIKE :phone', phone: "%#{params[:phone]}%").limit(10)
          when 'Partner'
            list = Partner.select(:id, :phone, :name).where('LOWER(phone) LIKE :phone', phone: "%#{params[:phone]}%").limit(10)
          else
            error!(failure_response_with_json("Given type is not matched",
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
          success_response_with_json('Successfully Search By Phone.', HTTP_CODE[:OK], list)
        rescue StandardError => error
          error!(failure_response_with_json("Something went wrong due to #{error.message}.",
                                            HTTP_CODE[:INTERNAL_SERVER_ERROR]), HTTP_CODE[:OK])
        end

        desc 'Filter And Search'
        params do
          requires :type, type: String
          requires :id, type: String
          optional :keyword, type: String
        end
        get :filter_and_search do
          keyword = params[:keyword].downcase if params[:keyword].present?
          case params[:type]
          when 'Warehouse'
            warehouse = Warehouse.find(params[:id].to_i)
            list = warehouse.districts
            list = list.where('LOWER(name) LIKE :keyword OR LOWER(bn_name) LIKE :keyword', keyword: "%#{keyword}%") if params[:keyword].present?
            list = list.select(:id, :name).limit(10)
          when 'District'
            district = District.find(params[:id].to_i)
            list = district.thanas
            list = list.where('LOWER(name) LIKE :keyword OR LOWER(bn_name) LIKE :keyword', keyword: "%#{keyword}%") if params[:keyword].present?
            list = list.select(:id, :name).limit(10)
          when 'Thana'
            thana = Thana.find(params[:id].to_i)
            list = thana.areas
            list = list.where('LOWER(name) LIKE :keyword OR LOWER(bn_name) LIKE :keyword', keyword: "%#{keyword}%") if params[:keyword].present?
            list = list.select(:id, :name).limit(10)
          else
            error!(failure_response_with_json("Given type is not matched",
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
          success_response_with_json('Successfully Filter and Search', HTTP_CODE[:OK], list)
        rescue StandardError => error
          error!(failure_response_with_json("Something went wrong due to #{error.message}.",
                                            HTTP_CODE[:INTERNAL_SERVER_ERROR]), HTTP_CODE[:OK])
        end

        desc 'list of Status'
        get :statuses do
          statuses = PromoCoupon.statuses.map { |k, v| { title: k.titleize, value: v } }

          success_response_with_json('Successfully fetch the list of status.', HTTP_CODE[:OK], statuses)
        rescue StandardError => error
          error!(failure_response_with_json("Something went wrong due to #{error.message}.",
                                            HTTP_CODE[:INTERNAL_SERVER_ERROR]), HTTP_CODE[:OK])
        end

        desc 'list of discount_types'
        get :discount_types do
          discount_types = PromoCoupon.discount_types.map { |k, v| { title: k.titleize, value: v } }

          success_response_with_json('Successfully fetch the list of discount_type.', HTTP_CODE[:OK], discount_types)
        rescue StandardError => error
          error!(failure_response_with_json("Something went wrong due to #{error.message}.",
                                            HTTP_CODE[:INTERNAL_SERVER_ERROR]), HTTP_CODE[:OK])
        end

        desc 'list of order_type'
        get :order_types do
          order_types = PromoCoupon.order_types.map { |k, v| { title: k.titleize, value: v } }

          success_response_with_json('Successfully fetch the list of order_type.', HTTP_CODE[:OK], order_types)
        rescue StandardError => error
          error!(failure_response_with_json("Something went wrong due to #{error.message}.",
                                            HTTP_CODE[:INTERNAL_SERVER_ERROR]), HTTP_CODE[:OK])
        end

        desc 'list of promo_coupon'
        params do
          use :pagination, per_page: 10
        end
        get do
          promo_coupons = PromoCoupon.all
          # TODO: Need to Optimize Query
          promo_coupons = paginate(Kaminari.paginate_array(promo_coupons))
          success_response_with_json('Successfully fetch the list of promo_coupon.', HTTP_CODE[:OK], promo_coupons)
        rescue StandardError => error
          error!(failure_response_with_json("Something went wrong due to #{error.message}.",
                                            HTTP_CODE[:INTERNAL_SERVER_ERROR]), HTTP_CODE[:OK])
        end

        desc 'Create a new PromoCoupon.'
        params do
          requires :promo_coupon, type: Hash do
            requires :title, type: String
            requires :status, type: Integer
            requires :order_type, type: Integer
            requires :discount_type, type: Integer
            requires :start_date, type: Date
            requires :end_date, type: Date
            requires :number_of_coupon, type: Integer
            optional :minimum_cart_value, type: Float
            optional :discount, type: Float
            optional :max_discount_amount, type: Float
            optional :promo_coupon_rules_attributes, type: Array do
              requires :ruleable_type, type: String
              requires :ruleable_id, type: Integer
            end
          end
        end
        desc 'Create a new PromoCoupon.'
        post do
          if params[:promo_coupon][:number_of_coupon] > 500
            error!(failure_response_with_json('Coupon can not generated more than 500.',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          rule_attributes = params[:promo_coupon][:promo_coupon_rules_attributes]
          rule_attributes_count = rule_attributes&.pluck(:ruleable_type)&.compact&.uniq&.count
          unless (0..2).include?(rule_attributes_count)
            error!(failure_response_with_json('Please select promo coupon rules properly.',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          promo_coupon = PromoCoupon.create!(params[:promo_coupon].merge!(created_by_id: @current_staff.id))
          promo_coupon.create_coupons(rule_attributes)
          promo_coupon = ShopothWarehouse::V1::Entities::PromoCoupons.represent(promo_coupon)
          success_response_with_json('Successfully Create PromoCoupon.', HTTP_CODE[:OK], promo_coupon)
        rescue StandardError => error
          Rails.logger.info "\n\nUnable to create PromoCoupon due to: #{error.message}"
          error!(failure_response_with_json('Unable to create PromoCoupon.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        route_param :id do
          before do
            @promo_coupon = PromoCoupon.includes(:promo_coupon_rules).find_by(id: params[:id])
            unless @promo_coupon
              error!(failure_response_with_json('PromoCoupon not found.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                     HTTP_CODE[:OK])
            end
          end
          desc 'Update a  PromoCoupon'
          params do
            requires :promo_coupon, type: Hash do
              requires :title, type: String
              requires :status, type: Integer
              requires :start_date, type: DateTime
              requires :end_date, type: DateTime
            end
          end
          put do
            @promo_coupon.update!(params[:promo_coupon])
            response = ShopothWarehouse::V1::Entities::PromoCoupons.represent(@promo_coupon)
            success_response_with_json('Successfully Update PromoCoupon.', HTTP_CODE[:OK], response)
          rescue StandardError => error
            Rails.logger.info "Update failed #{error.message}"
            error! failure_response_with_json("Unable to Update PromoCoupon. error: #{error}",
                                              HTTP_CODE[:INTERNAL_SERVER_ERROR])
          end

          desc 'Fetch a PromoCoupon'
          get do
            response = ShopothWarehouse::V1::Entities::PromoCoupons.represent(@promo_coupon)
            success_response_with_json('Successfully Fetch PromoCoupon.', HTTP_CODE[:OK], response)
          rescue StandardError => error
            Rails.logger.info "Fetched failed #{error.message}"
            error! failure_response_with_json("Unable to Fetched PromoCoupon. error: #{error}",
                                              HTTP_CODE[:INTERNAL_SERVER_ERROR])
          end
        end

        desc 'Promo coupons export.'
        get '/:id/export' do
          ShopothWarehouse::V1::Entities::CouponExport.represent(
            Coupon.joins(:promo_coupon).where('promo_coupons.id = ?', params[:id]).includes(promo_coupon: :promo_coupon_rules),
          )
        rescue StandardError => error
          Rails.logger.error "\n\n#{__FILE__}\nUnable to fetched coupon list of PromoCoupon due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetched coupon list of PromoCoupon.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
