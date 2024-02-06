# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class ContactUs < Ecommerce::Base
      namespace :contact_us do
        desc 'return list of contact us'
        params do
          use :pagination, per_page: 50
        end
        get do
          unless check_wh_warehouse
            error!(failure_response_with_json('You are not authorized to see', HTTP_CODE[:NOT_ACCEPTABLE], {}),
                   HTTP_CODE[:OK])
          end

          all_contacts = Contact.all
          all_contacts = Contact.search_by_email(params[:email]) if params[:email].present?
          all_contacts = Contact.search_by_phone(params[:phone]) if params[:phone].present?
          # TODO: Need to Optimize Query
          success_response_with_json('Successfully fetched',
                                     HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::ContactUs.
                                       represent(paginate(Kaminari.paginate_array(all_contacts.order(id: :desc)))))
        rescue StandardError => error
          Rails.logger.info "admin contact us list fetch failed #{error.message}"
          error!(failure_response_with_json('failed to fetch', HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                 HTTP_CODE[:OK])
        end

        route_param :id do
          get do
            unless check_wh_warehouse
              error!(failure_response_with_json('You are not authorized to see', HTTP_CODE[:NOT_ACCEPTABLE], {}),
                     HTTP_CODE[:OK])
            end

            contact = Contact.find(params[:id])
            success_response_with_json('Successfully fetched',
                                       HTTP_CODE[:OK],
                                       ShopothWarehouse::V1::Entities::ContactUs.represent(contact))
          rescue StandardError => error
            Rails.logger.info "admin contact us list fetch failed #{error.message}"
            error!(failure_response_with_json('failed to fetch', HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                   HTTP_CODE[:OK])
          end
        end
      end
    end
  end
end
