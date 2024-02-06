module Ecommerce
  module V1
    class PartnerSearch < Ecommerce::Base
      resource :partners do
        desc 'Get all partners based on area_id.'
        params do
          requires :area_id, type: Integer
        end
        route_setting :authentication, optional: true
        get do
          area = Area.find_by(id: params[:area_id])
          unless area
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.area_not_found'),
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          partners = Partner.active.joins(:address).where('addresses.area_id = ?', area.id)
          success_response_with_json(I18n.t('Ecom.success.messages.partner_fetch_successful'), HTTP_CODE[:OK],
                                     Ecommerce::V1::Entities::PartnersSearch.represent(partners))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch partners due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.partner_fetch_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Get selected partners with a specific store id, thana, area.'
        params do
          requires :district_id, type: Integer
          optional :store_identifier, type: String
          optional :thana_id, type: Integer
          optional :area_id, type: Integer
          optional :latitude, type: BigDecimal
          optional :longitude, type: BigDecimal
        end
        route_setting :authentication, optional: true
        get 'filter' do
          partners = Partner.active.where(is_b2b: false).joins(:address).where(addresses: { district_id: params[:district_id] })
          partners = partners.joins(:address).where(addresses: { thana_id: params[:thana_id] }) if params[:thana_id].present?
          partners = partners.joins(:address).where(addresses: { area_id: params[:area_id] }) if params[:area_id].present?
          partners = partners.where(
            'LOWER(partners.name) LIKE :identifier OR LOWER(partners.retailer_code) LIKE :identifier OR
             LOWER(partners.partner_code) LIKE :identifier', identifier: "%#{params[:store_identifier]&.downcase}%",
          )

          # default descending ordering
          partners = partners.order(created_at: :desc)
          # ordering based on location_difference
          if params[:latitude].present? && params[:longitude].present?
            partners = partners.sort_by { |partner|
              partner.location_difference(params[:latitude], params[:longitude])
            }
          end
          # # ordering based on favorite store
          if @current_user.present?
            favorite_stores_ids = @current_user.favorite_stores.pluck(:partner_id)
            partners = partners.sort_by { |partner| favorite_stores_ids.include?(partner.id) ? 0 : 1 }
          end
          partners = Ecommerce::V1::Entities::PartnersSearch.represent(partners, user: @current_user)

          success_response_with_json(I18n.t('Ecom.success.messages.partner_fetch_successful'), HTTP_CODE[:OK], partners)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch partner list due to: #{error.message}"
          error!(failure_response_with_json("#{I18n.t('Ecom.errors.messages.unable_to_process_request')} #{error}",
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
