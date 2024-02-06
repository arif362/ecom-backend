# frozen_string_literal: true

module Finance
  module V1
    class Warehouses < Finance::Base
      resource :warehouses do
        desc 'List of Distribution Warehouses for Finance Admin.'
        get do
          warehouses = Warehouse.where(warehouse_type: Warehouse::WAREHOUSE_TYPES[:distribution])
          present warehouses, with: Finance::V1::Entities::Warehouses
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch distribution warehouse list due to: #{error.message}"
          error!(respond_with_json('Unable to fetch distribution warehouse list.',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        route_param :id do
          before do
            @warehouse = Warehouse.find_by(id: params[:id])
            unless @warehouse
              error!(respond_with_json('Warehouse not found.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:OK])
            end
          end
          desc 'Get warehouse details.'
          get do
            present @warehouse, with: Finance::V1::Entities::Warehouse
          rescue StandardError => error
            Rails.logger.error "#{__FILE__} \nUnable to fetch Warehouse details due to: #{error.message}"
            error!(respond_with_json(I18n.t('Warehouse.errors.messages.warehouse_details_fetch_failed'),
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          desc 'Get partners margin list.'
          params do
            use :pagination, per_page: 25
            requires :month, type: Integer
            requires :year, type: Integer
            optional :skip_pagination, type: Boolean
          end
          get 'partners_margin' do
            start_date = DateTime.civil(params[:year], params[:month], 1).in_time_zone('Dhaka').beginning_of_day
            end_date = DateTime.civil(params[:year], params[:month], -1).in_time_zone('Dhaka').end_of_day
            completed_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
            partial_return_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:partially_returned])
            orders = @warehouse.customer_orders.where(
              status: [completed_status, partial_return_status], completed_at: start_date..end_date,
            ).includes(:partner_margin, :partner)

            orders = orders.order(created_at: :desc).select { |order| (order.induced? || (order.organic? && order.pick_up_point?)) }

            if orders.present?
              # TODO: Need to Optimize Query
              orders = paginate(Kaminari.paginate_array(orders)) unless params[:skip_pagination].present?
              present orders, with: Finance::V1::Entities::PartnerMargin
            else
              status :not_found
              { status_code: HTTP_CODE[:NOT_FOUND], message: 'Customer orders not found' }
            end
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to fetch order list due to: #{error.message}"
            error! respond_with_json("Unable to fetch order list due to #{error.message}",
                                     HTTP_CODE[:NOT_FOUND])
          end

          desc 'Get agent commission list.'
          params do
            use :pagination, per_page: 25
            requires :month, type: Integer
            requires :year, type: Integer
            optional :skip_pagination, type: Boolean
          end
          get 'agent_commission' do
            start_date = DateTime.civil(params[:year], params[:month], 1).in_time_zone('Dhaka').beginning_of_day
            end_date = DateTime.civil(params[:year], params[:month], -1).in_time_zone('Dhaka').end_of_day
            completed_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
            partial_return_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:partially_returned])
            orders = @warehouse.customer_orders.where(status: [completed_status, partial_return_status], completed_at: start_date..end_date).order(created_at: :desc)
            if orders.present?
              # TODO: Need to Optimize Query
              orders = paginate(Kaminari.paginate_array(orders)) unless params[:skip_pagination].present?
              present orders, with: Finance::V1::Entities::AgentCommission
            else
              status :not_found
              { status_code: HTTP_CODE[:NOT_FOUND], message: 'Customer orders not found' }
            end
          rescue StandardError => error
            error! respond_with_json("Unable to fetch order list due to #{error.message}",
                                     HTTP_CODE[:NOT_FOUND])
          end

          desc 'Get total fulfilment center commission and total partner margin.'
          params do
            requires :month, type: Integer
            requires :year, type: Integer
          end
          get 'total_commission_margin' do
            start_date = DateTime.civil(params[:year], params[:month], 1).in_time_zone('Dhaka').beginning_of_day
            end_date = DateTime.civil(params[:year], params[:month], -1).in_time_zone('Dhaka').end_of_day
            completed_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
            partial_return_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:partially_returned])
            orders = @warehouse.customer_orders.includes(:distributor_margin).where(
              status: [completed_status, partial_return_status], completed_at: start_date..end_date,
            )

            partners_margin = 0
            paid_partners_margin = 0
            fc_commission = 0
            paid_fc_commission = 0
            orders.each do |order|
              if order.aggregated_transaction_customer_orders&.agent_commission.present?
                paid_fc_commission += order.distributor_margin&.amount&.round(2)
              else
                fc_commission += order.distributor_margin&.amount&.round(2)
              end
            end

            # TODO: Need to optimize this (n*n) query.
            orders.where(partner_id: @warehouse.partners.ids).group_by(&:partner_id).each do |partner_id, orders|
              orders.each do |order|
                if (order.induced? || (order.organic? && order.pick_up_point?)) &&
                   order.aggregated_transaction_customer_orders&.sub_agent_commission.present?
                  paid_partners_margin += order.partner_margin&.margin_amount&.round(2)
                elsif order.induced? || (order.organic? && order.pick_up_point?)
                  partners_margin += order.partner_margin&.margin_amount&.round(2)
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
            Rails.logger.error "\n#{__FILE__}\nUnable to calculate commission due to: #{error.message}"
            error! respond_with_json("Unable to calculate commission due to #{error.message}",
                                     HTTP_CODE[:NOT_FOUND])
          end
        end
      end
    end
  end
end
