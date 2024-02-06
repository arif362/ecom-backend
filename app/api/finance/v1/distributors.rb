# frozen_string_literal: true

module Finance
  module V1
    class Distributors < Finance::Base
      resource :distributors do
        desc 'Get all distributors for Finance Admin.'
        get do
          Finance::V1::Entities::Distributors.represent(Distributor.all)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch distributors due to: #{error.message}"
          error!(respond_with_json('Unable to fetch distributors.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        route_param :id do
          before do
            @distributor = Distributor.find_by(id: params[:id])
            unless @distributor
              error!(respond_with_json('Distributor not found.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
          end

          desc 'Get distributor details for Finance Admin.'
          get do
            Finance::V1::Entities::Distributors.represent(@distributor)
          rescue StandardError => error
            Rails.logger.error "#{__FILE__} \nUnable to fetch distributor details due to: #{error.message}"
            error!(respond_with_json('Unable to fetch distributor details.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          desc 'Get partner margins for Finance Admin.'
          params do
            use :pagination, per_page: 25
            requires :month, type: Integer
            requires :year, type: Integer
            optional :skip_pagination, type: Boolean
          end
          get '/partner_margins' do
            start_date = DateTime.civil(params[:year], params[:month], 1).in_time_zone('Dhaka').beginning_of_day
            end_date = DateTime.civil(params[:year], params[:month], -1).in_time_zone('Dhaka').end_of_day
            statuses = OrderStatus.fetch_statuses(%w(completed partially_returned))
            orders = @distributor.customer_orders.where(status: statuses, completed_at: start_date..end_date).joins(:partner, :partner_margin)
            if orders.empty?
              error!(respond_with_json('Customer orders not found.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
            # TODO: Need to Optimize Query
            orders = if params[:skip_pagination]
                       orders.order(created_at: :desc)
                     else
                       paginate(Kaminari.paginate_array(orders.order(created_at: :desc)))
                     end

            Finance::V1::Entities::PartnerMargin.represent(orders)
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to fetch partner margins due to: #{error.message}"
            error!(respond_with_json('Unable to fetch partner margins.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          desc 'Get agent commissions for Finance Admin.'
          params do
            use :pagination, per_page: 25
            requires :month, type: Integer
            requires :year, type: Integer
            optional :skip_pagination, type: Boolean
          end
          get 'agent_commissions' do
            start_date = DateTime.civil(params[:year], params[:month], 1).in_time_zone('Dhaka').beginning_of_day
            end_date = DateTime.civil(params[:year], params[:month], -1).in_time_zone('Dhaka').end_of_day
            statuses = OrderStatus.fetch_statuses(%w(completed partially_returned))
            orders = @distributor.customer_orders.where(status: statuses, completed_at: start_date..end_date)
            if orders.empty?
              error!(respond_with_json('Customer orders not found.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
            # TODO: Need to Optimize Query
            orders = if params[:skip_pagination]
                       orders.order(created_at: :desc)
                     else
                       paginate(Kaminari.paginate_array(orders.order(created_at: :desc)))
                     end

            Finance::V1::Entities::AgentCommission.represent(orders)
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to fetch agent commissions due to: #{error.message}"
            error!(respond_with_json('Unable to fetch agent commissions.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          desc 'Get total commission and total partner margin.'
          params do
            requires :month, type: Integer
            requires :year, type: Integer
          end
          get 'total_commission_margin' do
            start_date = DateTime.civil(params[:year], params[:month], 1).in_time_zone('Dhaka').beginning_of_day
            end_date = DateTime.civil(params[:year], params[:month], -1).in_time_zone('Dhaka').end_of_day
            statuses = OrderStatus.fetch_statuses(%w(completed partially_returned))
            orders = @distributor.customer_orders.includes(:distributor_margin).where(
              status: statuses, completed_at: start_date..end_date,
            )

            partners_margin = 0
            paid_partners_margin = 0
            fc_commission = 0
            paid_fc_commission = 0
            orders.each do |order|
              if order.aggregated_transaction_customer_orders&.agent_commission.present?
                paid_fc_commission += order.distributor_margin&.amount&.round(2) || 0
              else
                fc_commission += order.distributor_margin&.amount&.round(2) || 0
              end
            end

            orders.where(partner_id: @distributor.partners.ids).group_by(&:partner_id).each do |partner_id, orders|
              orders.each do |order|
                if (order.induced? || (order.organic? && order.pick_up_point?)) &&
                   order.aggregated_transaction_customer_orders&.sub_agent_commission.present?
                  paid_partners_margin += order.partner_margin&.margin_amount&.round(2) || 0
                elsif order.induced? || (order.organic? && order.pick_up_point?)
                  partners_margin += order.partner_margin&.margin_amount&.round(2) || 0
                end
              end
              partners_margin = partners_margin.round(2)
              paid_partners_margin = paid_partners_margin.round(2)
            end

            fc_commission = fc_commission.round(2)
            paid_fc_commission = paid_fc_commission.round(2)
            status :ok
            {
              status_code: HTTP_CODE[:OK],
              total_partners_margin: partners_margin + paid_partners_margin,
              pending_partners_margin: partners_margin,
              paid_partners_margin: paid_partners_margin,
              total_fc_commission: fc_commission + paid_fc_commission,
              pending_fc_commission: fc_commission,
              paid_fc_commission: paid_fc_commission,
            }
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to calculate commissions due to: #{error.message}"
            error! respond_with_json("Unable to calculate commissions due to #{error.message}",
                                     HTTP_CODE[:NOT_FOUND])
          end
        end
      end
    end
  end
end
