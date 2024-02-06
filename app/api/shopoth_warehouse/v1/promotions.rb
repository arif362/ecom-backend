module ShopothWarehouse
  module V1
    class Promotions < ShopothWarehouse::Base

      # rubocop:disable Metrics/BlockLength
      resource :promotions do

        # GET /promotions/
        desc 'Get the promotion list'
        params do
          use :pagination, per_page: 50
        end
        get do
          promotions = Promotion.where.not(promotion_category: :flash_sale).
            includes(:warehouse).order(created_at: :desc)
          # TODO: Need to Optimize Query
          present paginate(Kaminari.paginate_array(promotions)), with: ShopothWarehouse::V1::Entities::Promotions,
                  list: true
        rescue StandardError => error
          error!("Unable to fetch promotion list due to #{error.message}")
        end

        # GET /promotions/settings
        desc 'Get promotion settings.'
        get '/settings' do
          Promotion.settings
        rescue StandardError => error
          error! respond_with_json("Unable to promotion configuration. error: #{error}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Coupons export'
        route_param :id do
          get 'coupons/export' do
            category = %i(customer_coupon minimum_cart_value)
            promotion = Promotion.where(promotion_category: category).find(params[:id])
            coupons = (promotion.coupons unless check_dh_warehouse)
            present coupons, with: ShopothWarehouse::V1::Entities::Coupons
          rescue StandardError => error
            error!(respond_with_json("Unable to fetch due to. error: #{error}",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        # GET /promotions/:id
        desc 'Get a Specific Promotion.'
        # route_setting :authentication, optional: true
        route_param :id do
          get do
            promotion = Promotion.includes(:promotion_rules, brand_promotions: :brand,
                                                             promotion_variants: :variant).find(params[:id])
            present promotion, with: ShopothWarehouse::V1::Entities::Promotions
          rescue StandardError
            error!(respond_with_json('Unable to Find promotion',
                                     HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end
        end

        # POST /promotions/
        desc 'Create a new promotion'
        params do
          requires :promotion, type: Hash do
            requires :title, type: String
            optional :warehouse_id, type: Integer
            requires :promotion_category, type: String
            requires :from_date, type: Date
            requires :to_date, type: Date
            optional :is_active, type: Boolean
            optional :is_time_bound, type: Boolean
            optional :start_time, type: String
            optional :end_time, type: String
            optional :days, type: Array
            requires :promotion_rule, type: Hash do
              requires :rule, type: String
              requires :fields, type: Array do
                requires :name, type: String
                requires :value, type: Array
              end
            end
          end
        end

        post do
          params[:promotion][:from_date] = params[:promotion][:from_date].to_datetime.utc
          params[:promotion][:to_date] = params[:promotion][:to_date].to_datetime.utc
          promotion = Promotion.new(params[:promotion].except(:promotion_rule).merge!(created_by_id: @current_staff.id))
          promotion.create_rules(params)
          if promotion.customer_coupon? || promotion.minimum_cart_value?
            promotion.value_for('coupons').to_i.times.each do
              Coupon.create!(promotion: promotion, code: SecureRandom.alphanumeric(6).upcase)
            end
          end
          promotion
        rescue StandardError => error
          Rails.logger.info "Unable to create Promotion. error: #{error.message}"
          error!(respond_with_json("Unable to create Promotion. error: #{error.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        # PUT /promotions/:id
        desc 'Update a promotion'
        params do
          requires :promotion, type: Hash do
            requires :title, type: String
            optional :warehouse_id, type: Integer
            optional :promotion_category, type: String
            requires :from_date, type: Date
            requires :to_date, type: Date
            optional :is_active, type: Boolean
            optional :is_time_bound, type: Boolean
            optional :start_time, type: String
            optional :end_time, type: String
            optional :days, type: Array
            optional :promotion_rule, type: Hash do
              optional :rule, type: String
              optional :fields, type: Array do
                optional :name, type: String
                optional :value, type: Array
              end
            end
          end
        end

        route_param :id do
          put do
            promotion = Promotion.find(params[:id])
            promotion = promotion.update_rules(params)
            promotion
          rescue StandardError => error
            Rails.logger.info "Unable to update Promotion. error: #{error.message}"
            error!(respond_with_json("Unable to update Promotion. error: #{error.message}",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
        end

        # DELETE /promotions/:id/
        desc 'Delete a promotion'
        route_param :id do
          delete do
            Promotion.find(params[:id]).update!(is_active: false)
            respond_with_json("Promotion is successfully made inactive with id #{params[:id]}",
                              HTTP_CODE[:OK])
          rescue StandardError => error
            error! respond_with_json("Unable to delete/make inactive Promotion. error: #{error}",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
