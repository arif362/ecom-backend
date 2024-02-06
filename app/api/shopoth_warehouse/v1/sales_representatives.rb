module ShopothWarehouse
  module V1
    class SalesRepresentatives < ShopothWarehouse::Base

      helpers do
        def schedule_matched?(partner)
          partner_schedule = partner.schedule
          current_day = Date.today.strftime("%A")[0..2].downcase
          partner_schedule.include?(current_day)
        end
      end
      resource :sales_representatives do

        # INDEX *************************************************
        desc 'Get all Sales Representatives'
        get do
          SalesRepresentative.all
        end

        desc 'Get sr app version config.'
        route_setting :authentication, optional: true
        get '/app_config' do
          Configuration.return_app_version_config('sr_app')
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nSR app version config fetch failed due to: #{error.message}"
          error!(respond_with_json('SR app version config fetch failed.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Get all partners based on warehouse_id.'
        route_setting :authentication, type: RouteDevice
        get '/partners' do
          status_type = %w(delivered_to_partner completed)
          statuses = OrderStatus.fetch_statuses(status_type).ids.join(',')
          route = @current_route_device.route
          partners = Partner.fetch_route_partners(statuses, route)
          partners = partners.select{|partner| schedule_matched?(partner)}
          present partners, with: ShopothWarehouse::V1::Entities::SrPartners,
                            language: request.headers['Language-Type']
        rescue StandardError => error
          error! respond_with_json(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Get all partners by schedule'
        route_setting :authentication, type: RouteDevice
        get 'partners_by_schedule' do
          partners = @current_route_device.route.partners.order('id ASC')
          selected_partners = partners.select do |partner|
            schedule_matched?(partner)
          end
          if request.headers['Language-Type'] == 'en'
            present selected_partners, with: ShopothWarehouse::V1::Entities::ModifiedEnPartners
          else
            present selected_partners, with: ShopothWarehouse::V1::Entities::ModifiedBnPartners
          end
        rescue StandardError => ex
          error! respond_with_json("Unable to fetch partners due to #{ex.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # CREATE ************************************************
        desc 'Create a new Sales Representative'
        params do
          requires :warehouse_id, type: Integer
          requires :name, type: String
          requires :area, type: String
        end

        post do
          sales_representative = SalesRepresentative.new(params)
          sales_representative if sales_representative.save!
        rescue StandardError
          error! respond_with_json('Unable to create Sales_Representative.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # UPDATE ************************************************
        desc 'Update a Sales Representative'
        params do
          requires :id, type: String, desc: 'Identification'
        end

        route_param :id do
          put do
            sales_representative = SalesRepresentative.find(params[:id])
            sales_representative if sales_representative.update!(params)
          rescue StandardError
            error! respond_with_json('Unable to update Sales_Representative.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        # DELETE ************************************************
        desc 'Delete a Sales Representative'
        params do
          requires :id, type: String, desc: 'Identification'
        end

        route_param :id do
          delete do
            sales_representative = SalesRepresentative.find(params[:id])
            'Successfully deleted.' if sales_representative.destroy!
          rescue StandardError
            error! respond_with_json('Unable to delete Sales_Representative.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'implement sr reports'
        route_setting :authentication, type: RouteDevice
        params do
          requires :partner_id, type: Integer, allow_blank: false
        end
        get 'reports' do
          partner_id = params[:partner_id]
          if partner_id.to_i.zero?
            partners = @current_route_device.route.partners
            error! respond_with_json('No partner associate with the SR', HTTP_CODE[:UNPROCESSABLE_ENTITY]) unless
              partners.present?
            report_context = SrReports::GenerateReport.call(partners: partners)
          else
            partner = @current_route_device.route.partners.find(partner_id)
            report_context = SrReports::GenerateReport.call(partners: partner)
          end
          if report_context.success?
            report_context.report_hash
          else
            error! respond_with_json('Unable to generate report', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        # rescue => ex
        #   error! respond_with_json("Unable to generate report due to #{ex.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'implement sr report payout'
        route_setting :authentication, type: RouteDevice
        params do
          requires :partner_id, type: Integer, allow_blank: false
          optional :filter_time, type: String
        end
        get 'payout' do
          partner_id = params[:partner_id]
          time = params[:filter_time]
          if partner_id.to_i.zero?
            partners = @current_route_device.route.partners
            error! respond_with_json('No partner associate with the SR', HTTP_CODE[:UNPROCESSABLE_ENTITY]) unless
              partners.present?
            payout_context = SrReports::GeneratePayout.call(partners: partners, time: time, current_route_device: @current_route_device)
          else
            partner = @current_route_device.route.partners.find(partner_id)
            payout_context = SrReports::GeneratePayout.call(partners: partner, time: time, current_route_device: @current_route_device)
          end
          if payout_context.success?
            payout_context.payout_hash
          else
            error! respond_with_json('Unable to generate payout', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        rescue StandardError => ex
          error! respond_with_json("Unable to generate payout due to #{ex.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Implement sr receive margin.'
        route_setting :authentication, type: RouteDevice
        params do
          optional :month, type: Integer
          optional :year, type: Integer
        end
        post 'receive_margin' do
          route = @current_route_device&.route
          start_date = DateTime.civil(params[:year], params[:month], 1).in_time_zone('Dhaka').beginning_of_day
          end_date = DateTime.civil(params[:year], params[:month], -1).in_time_zone('Dhaka').end_of_day
          fc_payments = AggregatedTransaction.sub_agent_commission.where(
            month: params[:month], year: params[:year],
          )
          payment_found = false
          fc_payments.each do |payment|
            if payment&.bank_transaction&.transactionable_to == route&.distributor
              payment_found = true
              break
            end
          end

          unless payment_found
            return respond_with_json('DH not paid yet for this month.', HTTP_CODE[:NOT_FOUND])
          end

          existing_payment = AggregatedPayment.sr_margin.where(month: params[:month], year: params[:year],
                                                               received_by: route)
          if existing_payment.present?
            return respond_with_json('Payment already received.', HTTP_CODE[:NOT_ACCEPTABLE])
          end

          ActiveRecord::Base.transaction do
            aggregated_payment = AggregatedPayment.sr_margin.create!(
              month: params[:month], year: params[:year], received_by: route,
            )
            total_amount = route.create_aggregated_SR_payment(aggregated_payment, route.partners, start_date, end_date)

            if total_amount.positive?
              Payment.create!(aggregated_payment: aggregated_payment,
                              currency_amount: total_amount,
                              currency_type: 'BDT',
                              status: :successful,
                              form_of_payment: :cash,
                              paymentable: route.distributor,
                              receiver: route)

              aggregated_payment.aggregated_payment_customer_orders.each do |a_order|
                margin_amount = a_order.customer_order.partner_margin&.margin_amount || 0
                a_order.customer_order.partner_margin.update!(
                  route_received_at: Time.now, route_received_amount: margin_amount,
                )
              end
              respond_with_json('Margin received successfully.', HTTP_CODE[:OK])
            else
              aggregated_payment.destroy
              respond_with_json('Payment amount not positive.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to receive margin due to: #{error.message}"
          error! respond_with_json("Unable to receive margin due to #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end

