module Ecommerce
  module V1
    class PartnerRanking < Ecommerce::Base
      helpers do
        def date_options
          {
            mega: {
              start_date: Date.parse('17-10-2021').beginning_of_day,
              end_date: Date.parse('14-11-2021').end_of_day,
            },
            week1: {
              start_date: Date.parse('17-10-2021').beginning_of_day,
              end_date: Date.parse('23-10-2021').end_of_day,
            },
            week2: {
              start_date: Date.parse('24-10-2021').beginning_of_day,
              end_date: Date.parse('30-10-2021').end_of_day
            },
            week3: {
              start_date: Date.parse('31-10-2021').beginning_of_day,
              end_date: Date.parse('06-11-2021').end_of_day,
            },
            week4: {
              start_date: Date.parse('07-11-2021').beginning_of_day,
              end_date: Date.parse('14-11-2021').end_of_day,
            }
          }
        end
      end

      resources :partner_ranking do
        desc 'get date filter options'
        route_setting :authentication, optional: true

        get '/date_options' do
          data = []
          date_options.each do |key, date_range|
            data << { key: key, value: I18n.t("Partner.ranking.#{key}") }
          end

          {
            message: I18n.t("Partner.success.messages.ranking_date_options_fetched_successfully"),
            status_code: HTTP_CODE[:OK],
            data: data,
          }
        rescue => error
          Rails.logger.error("Partner ranking date options fetch failed due to #{error}")
          error!(I18n.t('Partner.errors.messages.ranking_date_options_fetch_failed'), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Fetch partner list for ranking'
        route_setting :authentication, optional: true
        params do
          use :pagination, per_page: 20
          optional :district_id, type: Integer
          optional :partner_code, type: String
          optional :date_option_key, type: String
        end
        get '/list' do
          partners = Partner.active
          unless params[:district_id].present?
            error!(respond_with_json('Please provide district_id.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          partners = partners.joins(:address).where(addresses: { district_id: params[:district_id] }) if params[:district_id].present?

          completed = OrderStatus.getOrderStatus('completed').id
          partially_returned = OrderStatus.getOrderStatus('partially_returned').id
          date_key = params[:date_option_key] || 'mega'
          date_option = date_options[:"#{date_key}"]

          partners = partners.sort_by{ |partner|
            customer_orders = partner.customer_orders.where(created_at: date_option[:start_date]..date_option[:end_date])
            [customer_orders.where(order_status_id: [completed, partially_returned]).count, customer_orders.count, (partner&.partner_code.to_s)]
          }.reverse
          partners = partners.each_with_index {|partner, index| partner.update(ranking: (index + 1))}
          partners = partners.select {|partner| partner&.partner_code&.include?(params[:partner_code])} if params[:partner_code].present?

          formatted_data = Ecommerce::V1::Entities::PartnersRanking.represent(partners, date_option: date_option, completed: completed, partially_returned: partially_returned)
          # TODO: Need to Optimize Query
          {
            message: I18n.t('Partner.success.messages.ranking_list_fetched_successfully'),
            status_code: HTTP_CODE[:OK],
            data: paginate(Kaminari.paginate_array(formatted_data)),
          }
        rescue => error
          Rails.logger.error("Partner ranking list fetch failed due to #{error}")
          error!(I18n.t('Partner.errors.messages.ranking_list_fetch_failed'), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
