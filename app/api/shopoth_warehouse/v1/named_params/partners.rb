module ShopothWarehouse
  module V1
    module NamedParams
      module Partners
        extend ::Grape::API::Helpers

        params :partner_list_by_area do
          requires :area_id, type: Integer
        end

        params :fetch_delivery_list do
          optional :partner_id, type: Integer
        end

        params :return_delivery_history_list do
          optional :partner_id, type: Integer
        end

        params :partner_order_completion_list do
          requires :month, type: Integer
          requires :year, type: Integer
        end

        params :list_of_partner_params do
          use :pagination, per_page: 50
        end

        params :create_partner_params do
          requires :partner, type: Hash do
            requires :route_id, type: Integer
            requires :name, type: String
            requires :password, type: String
            requires :password_confirmation, type: String
            requires :phone, type: String
            optional :image_file
            optional :email, type: String
            optional :status, type: String
            requires :schedule, type: String
            requires :slug, type: String
            optional :tsa_id, type: String
            optional :retailer_code, type: String
            optional :partner_code, type: String
            optional :region, type: String
            optional :area, type: String
            optional :territory, type: String
            optional :point, type: String
            optional :owner_name, type: String
            optional :cluster_name, type: String
            optional :sub_channel, type: String
            optional :bn_name, type: String
            optional :latitude, type: BigDecimal
            optional :longitude, type: BigDecimal
            optional :bkash_number, type: String
            optional :business_type, type: String, values: Partner.business_types.keys
            optional :work_days, type: Array do
              requires :day_index, type: Integer
              requires :is_opened, type: Boolean
              requires :opening_time, type: String
              requires :closing_time, type: String
            end
            optional :is_commission_applicable, type: Boolean
            optional :meta_datum_attributes, type: Hash do
              optional :meta_keyword, type: Array
              optional :bn_meta_keyword, type: Array
              optional :meta_title, type: String
              optional :bn_meta_title, type: String
              optional :meta_description, type: String
              optional :bn_meta_description, type: String
            end
          end
          optional :address_attributes, type: Hash do
            requires :area_id, type: Integer
            requires :address_line, type: String
          end
        end

        params :update_partner_params do
          requires :partner, type: Hash do
            optional :route_id, type: Integer
            optional :name, type: String
            optional :password, type: String
            optional :password_confirmation, type: String
            optional :phone, type: String
            optional :image_file
            optional :email, type: String
            optional :status, type: String
            optional :schedule, type: String
            optional :slug, type: String
            optional :tsa_id, type: String
            optional :retailer_code, type: String
            optional :partner_code, type: String
            optional :region, type: String
            optional :area, type: String
            optional :territory, type: String
            optional :point, type: String
            optional :owner_name, type: String
            optional :cluster_name, type: String
            optional :sub_channel, type: String
            optional :bn_name, type: String
            optional :latitude, type: BigDecimal
            optional :longitude, type: BigDecimal
            optional :bkash_number, type: String
            optional :business_type, type: String, values: Partner.business_types.keys
            optional :work_days, type: Array do
              requires :day_index, type: Integer
              requires :is_opened, type: Boolean
              requires :opening_time, type: String
              requires :closing_time, type: String
            end
            optional :is_commission_applicable, type: Boolean
            optional :meta_datum_attributes, type: Hash do
              optional :meta_keyword, type: Array
              optional :bn_meta_keyword, type: Array
              optional :meta_title, type: String
              optional :bn_meta_title, type: String
              optional :meta_description, type: String
              optional :bn_meta_description, type: String
            end
          end
          optional :address_attributes, type: Hash do
            optional :area_id, type: Integer
            optional :address_line, type: String
          end
        end

        params :customer_orders_of_a_specific_partner do
          use :pagination, per_page: 50
        end
      end
    end
  end
end