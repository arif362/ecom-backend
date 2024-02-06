# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class Riders < ShopothWarehouse::Base
      helpers do
        def failed_qc_create(return_order, warehouse, failed_reasons)
          if return_order.unpacked?
            return_order.failed_qcs.create!(variant_id: return_order.shopoth_line_item.variant_id,
                                            quantity: 1, warehouse: warehouse, failed_reasons: failed_reasons,
                                            qc_failed_type: 'quality_failed')
            return_order.update_inventory_and_stock_changes('return_qc_failed_quantity', 'return_qc_pending_quantity')
          else
            return_order.customer_order.shopoth_line_items.each do |line_item|
              return_order.failed_qcs.create!(
                variant_id: line_item.variant_id, quantity: line_item.quantity,
                warehouse: warehouse, failed_reasons: failed_reasons,
                qc_failed_type: 'quality_failed', customer_order_id: return_order.customer_order.id
              )
            end
            return_order.update_inventory_and_stock_changes('return_qc_failed_quantity', 'return_qc_pending_quantity')
          end
        end
      end
      resource :riders do
        desc 'Get all riders for export.'
        get '/export' do
          riders = check_wh_warehouse ? Rider.all : @current_staff.warehouse.riders
          present riders, with: ShopothWarehouse::V1::Entities::Riders
        end

        params do
          use :pagination, per_page: 50
        end

        desc 'Get all riders.'
        get do
          riders = check_dh_warehouse ? @current_staff.warehouse.riders : Rider.all
          riders = riders.where(distributor_id: params[:distributor_id]) if params[:distributor_id].present?
          # TODO: Need to Optimize Query
          present paginate(Kaminari.paginate_array(riders)), with: ShopothWarehouse::V1::Entities::Riders
        end

        desc 'Get collection details of reconciliation for riders.'
        params do
          optional :start_date_time, type: DateTime
          optional :end_date_time, type: DateTime
        end

        get ':id/cash_collected_summary' do
          rider = @current_staff.warehouse.riders.find(params[:id])
          unless rider
            error!(respond_with_json('Unable to find rider.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : Time.now.at_beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= 3.month
            return respond_with_json("The selected date range (start_date: #{start_date_time} and end_date: #{end_date_time}) is not valid! Please select a  range within 3 months.", HTTP_CODE[:NOT_ACCEPTABLE])
          end

          date_range = start_date_time..end_date_time

          rider_return_orders = rider.return_customer_orders.joins(:return_status_changes).where(
            "return_status_changes.status = 'in_transit'",
          ).where(return_status_changes: { created_at: date_range })

          dh_return_orders = rider_return_orders.select { |order| order.return_status_changes.find_by(status: :qc_pending).present? }

          r_customer_orders = rider.customer_orders.joins(:payments).where("payments.paymentable_type = 'User'
          AND payments.receiver_type = 'Rider'").where(
            payments: { created_at: date_range },
          )

          dh_customer_orders_amount = r_customer_orders.sum do |order|
            order.payments.where("payments.paymentable_type = 'Rider' AND payments.receiver_type = 'Staff'").sum(&:currency_amount)
          end

          riders_order_count(r_customer_orders.sum(:currency_amount), dh_customer_orders_amount,
                             rider_return_orders, dh_return_orders)
        rescue StandardError => error
          error!(respond_with_json("Unable to find rider's Information due to #{error.message}.", HTTP_CODE[:NOT_FOUND]),
                 HTTP_CODE[:NOT_FOUND])
        end

        desc 'Get date_range filtered orders of riders.'
        params do
          use :pagination, per_page: 50
        end
        get ':id/cash_collected_orders' do
          rider = @current_staff.warehouse.riders.find(params[:id])
          unless rider
            error!(respond_with_json('Unable to find rider.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : Time.now.at_beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= 3.month
            return respond_with_json("The selected date range (start_date: #{start_date_time} and end_date: #{end_date_time}) is not valid! Please select a  range within 3 months.", HTTP_CODE[:NOT_ACCEPTABLE])
          end

          date_range = start_date_time..end_date_time
          customer_orders = rider.customer_orders.joins(:payments).where("payments.paymentable_type = 'User'
            AND payments.receiver_type = 'Rider'").where(payments: { created_at: date_range }).includes(:payments)
          # TODO: Need to Optimize Query
          present paginate(Kaminari.paginate_array(customer_orders.order(created_at: :desc))),
                  with: ShopothWarehouse::V1::Entities::ReconciliationOrderDetailsByRiders
        rescue StandardError => error
          error!(respond_with_json("Unable to find rider's customer order due to #{error.message}", HTTP_CODE[:NOT_FOUND]),
                 HTTP_CODE[:NOT_FOUND])
        end

        desc 'Get all return_customer_orders of a specific rider.'
        params do
          use :pagination, per_page: 50
        end
        get ':id/return_requests' do
          status = %w(in_transit qc_pending relocation_pending completed)
          warehouse = @current_staff.warehouse
          rider = warehouse.riders.find(params[:id])
          return_requests = rider.return_customer_orders.where(return_status: status).order(id: :desc)
          # TODO: Need to Optimize Query
          return_requests = paginate(Kaminari.paginate_array(return_requests))
          ShopothWarehouse::V1::Entities::ReturnRequestWithLocations.represent(return_requests,
                                                                               warehouse: warehouse)
        rescue StandardError => error
          Rails.logger.info "\n#{__FILE__}\nrReturn request fetch failed due to:  #{error.message}"
          error!(respond_with_json('Return request fetch failed.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end

        desc 'Get all Returned customer_orders of a specific rider.'
        params do
          use :pagination, per_page: 50
        end
        get ':id/return_orders' do
          rider = @current_staff.warehouse.riders.find(params[:id])
          order_status = %w(in_transit_cancelled in_transit_reschedule in_transit_delivery_switch)
          customer_orders = rider.customer_orders.map do |customer_order|
            customer_order if order_status.include?(customer_order.status.order_type.to_s)
          end.flatten.compact
          # TODO: Need to Optimize Query
          present paginate(Kaminari.paginate_array(customer_orders)),
                  with: ShopothWarehouse::V1::Entities::CustomerOrderList
        end

        desc "Return a specific rider's information."
        route_param :id do
          get do
            rider = Rider.find(params[:id])
            present rider, with: ShopothWarehouse::V1::Entities::Riders
          rescue StandardError => error
            error! respond_with_json(error, HTTP_CODE[:NOT_FOUND])
          end
        end

        params do
          requires :rider, type: Hash do
            requires :name, type: String
            requires :phone, type: String
            requires :password_hash, type: String
            optional :email, type: String
            requires :distributor_id, type: Integer
          end
        end

        desc 'Create a rider'
        post do
          if check_wh_warehouse
            error!(respond_with_json('You are not allowed to create any rider',
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
          phone = params[:rider][:phone].to_s.bd_phone
          unless phone
            Rails.logger.info '__________Phone number is not valid.__________'
            error!(respond_with_json('Phone number is not valid.', HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:NOT_ACCEPTABLE])
          end

          existing_rider = Rider.find_by_phone(phone)
          if existing_rider
            Rails.logger.info '__________Phone number exists.__________'
            error!(respond_with_json('Phone number is already been taken.', HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:NOT_ACCEPTABLE])
          end

          distributor = @current_staff.warehouse.distributors.find_by(id: params[:rider][:distributor_id])

          unless distributor
            error!(respond_with_json('Distributor not found', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          rider = distributor.riders.new(name: params[:rider][:name],
                                         phone: phone,
                                         password: params[:rider][:password_hash],
                                         email: params[:rider][:email],
                                         warehouse: @current_staff.warehouse,
                                         created_by_id: @current_staff.id)
          if rider.save!
            respond_with_json('Successfully created', HTTP_CODE[:CREATED])
          else
            respond_with_json(
              rider.errors.full_messages.to_sentence,
              HTTP_CODE[:UNPROCESSABLE_ENTITY],
            )
          end
        end

        desc 'Receive return order from riders'
        put '/receive_return_order/:id' do
          return_order = ReturnCustomerOrder.find(params[:id])
          warehouse = @current_staff.warehouse
          if warehouse == return_order.warehouse && return_order.in_transit?
            return_order.update!(return_status: :qc_pending, qc_status: :pending, changeable: @current_staff)
            warehouse.update(return_count: (warehouse.return_count.to_i + 1))
            status :ok
            respond_with_json('Return Order Received', HTTP_CODE[:OK])
          else
            error!(respond_with_json('Return Order can not be received.',
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        rescue StandardError
          error!(respond_with_json('You have given wrong return_order id.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Receive customer order from riders.'
        put '/receive_order/:id' do
          customer_order = CustomerOrder.find(params[:id])
          if customer_order.present? && customer_order.rider.warehouse == @current_staff.warehouse
            ActiveRecord::Base.transaction do
              order_status = customer_order.status
              if order_status.in_transit_cancelled?
                status = OrderStatus.getOrderStatus(OrderStatus.order_types[:packed_cancelled])
              else
                status = OrderStatus.getOrderStatus(OrderStatus.order_types[:ready_to_shipment])
                if order_status.in_transit_delivery_switch?
                  customer_order.update(partner_id: customer_order.next_partner_id,
                                        shipping_type: customer_order.next_shipping_type, rider_id: nil)
                end
              end
              update_stock(customer_order, @current_warehouse.id)
              customer_order.update!(order_status_id: status.id, changed_by: @current_staff)
            end
            respond_with_json('Customer Order Received.', HTTP_CODE[:OK])
          else
            error!(respond_with_json("Couldn't Find Customer Order with id: #{params[:id]}",
                                     HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end
        rescue StandardError
          error!(respond_with_json('You have given wrong customer_order id.',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        params do
          requires :rider, type: Hash do
            requires :name, type: String
            requires :phone, type: String
            optional :password_hash, type: String
            optional :email, type: String
            optional :distributor_id, type: Integer
          end
        end

        desc "Update a specific rider's information."
        put ':id' do
          if check_wh_warehouse
            error!(respond_with_json('You are not allowed to update any rider.',
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          if params[:rider][:phone].present?
            phone = params[:rider][:phone].to_s.bd_phone
            unless phone
              Rails.logger.info '__________Phone number is not valid.__________'
              error!(respond_with_json('Phone number is not valid.', HTTP_CODE[:NOT_ACCEPTABLE]),
                     HTTP_CODE[:NOT_ACCEPTABLE])
            end

            existing_rider = Rider.find_by_phone(phone)
          end

          rider = Rider.find(params[:id])
          if existing_rider && existing_rider != rider
            Rails.logger.info '__________Phone number exists.__________'
            error!(respond_with_json('Phone number is already been taken.', HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:NOT_ACCEPTABLE])
          end

          rider_params = {}
          rider_params[:name] = params[:rider][:name].present? ? params[:rider][:name] : rider.name
          rider_params[:phone] = params[:rider][:phone].present? ? phone : rider.phone
          rider_params[:email] = params[:rider][:email].present? ? params[:rider][:email] : rider.email
          rider_params[:password] = params[:rider][:password_hash] if params[:rider][:password_hash].present?
          if params[:rider][:distributor_id].present? && rider.distributor_id != params[:rider][:distributor_id] && rider.customer_orders.present?
            error!(respond_with_json("Distributor can't be changed because rider has customer orders.",
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
          end

          rider_params[:distributor_id] = params[:rider][:distributor_id].present? ? params[:rider][:distributor_id] : rider.distributor_id
          rider.update!(rider_params)
          present rider, with: ShopothWarehouse::V1::Entities::Riders
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to update rider due to: #{error.message}"
          error!(respond_with_json('Unable to update Rider.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Delete a specific rider.'
        route_param :id do
          delete do
            if check_wh_warehouse
              error!(respond_with_json('Not permitted to delete', HTTP_CODE[:FORBIDDEN]),
                     HTTP_CODE[:FORBIDDEN])
            end
            rider = @current_staff.warehouse.riders.find_by(id: params[:id])
            unless rider.present?
              error!(respond_with_json('Rider not found', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
            if rider.customer_orders.present?
              error!(respond_with_json('Rider has orders, hence can not be deleted', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
            respond_with_json('Successfully deleted', HTTP_CODE[:OK]) if rider.destroy!
          rescue StandardError => error
            Rails.logger.info "Can not delete #{error.message}"
            error!(respond_with_json('Unable to delete', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Wallet balance of a specific Rider.'
        route_param :id do
          get '/rider_wallet' do
            rider = Rider.find(params[:id])
            if @current_staff&.warehouse&.riders&.include?(rider)
              present rider, with: ShopothWarehouse::V1::Entities::RiderWalletBalances
            else
              error!(respond_with_json("Couldn't find rider with id: #{params[:id]}", HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
          rescue StandardError => error
            error!(respond_with_json("Failed: #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Collect Payment of all orders for a specific Rider.'
        params do
          optional :start_date_time, type: DateTime
          optional :end_date_time, type: DateTime
        end
        post ':id/cash_receive' do
          rider = @current_staff.warehouse.riders.find(params[:id])
          unless rider
            error!(respond_with_json('Unable to find rider.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : Time.now.at_beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= 3.month
            return respond_with_json("The selected date range (start_date: #{start_date_time} and end_date: #{end_date_time}) is not valid! Please select a  range within 3 months.", HTTP_CODE[:NOT_ACCEPTABLE])
          end

          date_range = start_date_time..end_date_time
          customer_orders = rider.customer_orders.joins(:payments).where("payments.paymentable_type = 'User'
            AND payments.receiver_type = 'Rider'").where(payments: { created_at: date_range })
          customer_orders = customer_orders.select do |order|
            order.payments.find_by(receiver_type: 'Staff').nil?
          end

          if customer_orders
            total_payment = 0
            customer_orders.each do |order|
              total_amount = order.payments.where("payments.paymentable_type = 'User' AND payments.receiver_type = 'Rider'").sum(&:currency_amount)
              rider.payments.create(currency_amount: total_amount,
                                    currency_type: 'BDT',
                                    status: :successful,
                                    form_of_payment: :cash,
                                    customer_order_id: order.id,
                                    receiver_id: @current_staff.id,
                                    receiver_type: @current_staff.class.to_s)
              total_payment += total_amount
              order.update(pay_status: :dh_received)
            end

            respond_with_json('Customer Orders payments received by Fulfillment Center.', HTTP_CODE[:OK])
          else
            error!(respond_with_json('Unable to find Customer Orders.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end
        rescue StandardError => error
          error!(respond_with_json("Unable to find Rider due to #{error}.", HTTP_CODE[:NOT_FOUND]),
                 HTTP_CODE[:NOT_FOUND])
        end

        desc 'Collect Money from Customer.'
        post '/collect_money' do
          params do
            requires :rider_id, type: Integer
            requires :money_type, type: String
          end
          rider = Rider.find(params[:rider_id])

          if @current_staff&.warehouse&.riders&.include?(rider)
            warehouse = @current_staff.warehouse
            case params[:money_type]
            when 'Cash'
              warehouse.update(collected_cash_from_routes: (warehouse.collected_cash_from_routes + rider.cash_collected))
              rider.update(cash_collected: 0.0)
            when 'wallet'
              warehouse.create_wallet(currency_amount: 0.0, currency_type: 'Tk.') if warehouse.wallet.nil?
              warehouse.wallet.update(currency_amount: (warehouse.wallet.currency_amount + rider.wallet.currency_amount))
              rider.wallet.update(currency_amount: 0.0)
            end
            respond_with_json('Money collected', HTTP_CODE[:OK])
          else
            error!(respond_with_json('Rider not found in Warehouse', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end
        rescue => error
          error! respond_with_json("Failed : #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc "Quality control for Rider's Return_customer_orders."
        params do
          requires :return_order_id, type: Integer
          requires :failed_reasons, type: Array
        end

        post ':id/return_qc' do
          warehouse = @current_staff.warehouse
          rider = warehouse.riders.find(params[:id])
          return_order = rider.return_customer_orders.find(params[:return_order_id])
          failed_reasons = params[:failed_reasons]

          if return_order.qc_pending? && failed_reasons.count.positive?
            ActiveRecord::Base.transaction do
              failed_qc_create(return_order, warehouse, failed_reasons)
              return_order.update!(return_status: :completed, qc_status: :failed, changeable: @current_staff)
            end
            respond_with_json('Qc failed.', HTTP_CODE[:OK])
          elsif return_order.qc_pending?
            ActiveRecord::Base.transaction do
              return_order.update!(return_status: :relocation_pending, qc_status: :passed, changeable: @current_staff)
              return_order.update_inventory_and_stock_changes('return_location_pending_quantity', 'return_qc_pending_quantity')
            end
            respond_with_json('Qc passed.', HTTP_CODE[:OK])
          else
            error!(respond_with_json('Unable to find Return Customer Order', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end
        rescue StandardError => error
          error!(respond_with_json("Unable to complete QC due to #{error.message}.",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
