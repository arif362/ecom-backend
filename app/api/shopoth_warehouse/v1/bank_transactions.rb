# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class BankTransactions < ShopothWarehouse::Base
      resource :bank_transactions do
        desc 'Get all BankTransactions for FC.'
        params do
          use :pagination, per_page: 50
        end
        get do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_day
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= 3.month
            return respond_with_json("The selected date range (start_date: #{start_date_time} and end_date: #{end_date_time}) is not valid! Please select a range within 3 months.", HTTP_CODE[:NOT_ACCEPTABLE])
          end

          date_range = start_date_time..end_date_time

          bank_transactions = BankTransaction.where(transactionable_by: @current_staff.warehouse).where(created_at: date_range).includes(:transactionable_by, :credit_bank_account, transactionable_for: :aggregated_transaction_customer_orders)
          # TODO: Need to Optimize Query
          present paginate(Kaminari.paginate_array(bank_transactions.order(id: :desc))), with:
            ShopothWarehouse::V1::Entities::BankTransactions
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch bank_transaction list due to: #{error.message}"
          error!(respond_with_json('Unable to fetch bank_transaction list.',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'List of Commission Bank Transactions for Warehouse admin.'
        params do
          use :pagination, per_page: 50
          requires :month, type: Integer
          requires :year, type: Integer
          optional :transaction_type, type: Integer
        end
        get 'commissions' do
          start_date_time = DateTime.civil(params[:year], params[:month], 1).in_time_zone('Dhaka').beginning_of_day
          end_date_time = DateTime.civil(params[:year], params[:month], -1).in_time_zone('Dhaka').end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= 3.month + 1.day
            error!(respond_with_json("The selected date range (start_date: #{start_date_time} and end_date: #{end_date_time}) is not valid! Please select a range within 3 months.",
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          date_range = start_date_time..end_date_time
          bank_transactions = if params[:transaction_type].present?
                                unless [1, 2].include?(params[:transaction_type])
                                  error!(respond_with_json('Please provide a valid transaction_type.',
                                                           HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
                                end
                                BankTransaction.joins("INNER JOIN aggregated_transactions ON bank_transactions.transactionable_for_id = aggregated_transactions.id AND bank_transactions.transactionable_for_type = 'AggregatedTransaction'").where(aggregated_transactions: { transaction_type: params[:transaction_type] }, created_at: date_range, transactionable_to: @current_staff.warehouse)
                              else
                                BankTransaction.joins("INNER JOIN aggregated_transactions ON bank_transactions.transactionable_for_id = aggregated_transactions.id AND bank_transactions.transactionable_for_type = 'AggregatedTransaction'").where(aggregated_transactions: { transaction_type: [1, 2] }, created_at: date_range, transactionable_to: @current_staff.warehouse)
                              end
          # TODO: Need to Optimize Query
          present paginate(Kaminari.paginate_array(bank_transactions)), with:
              ShopothWarehouse::V1::Entities::AgentBankTransaction
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch bank transaction list due to: #{error.message}"
          error!(respond_with_json('Unable to fetch bank transaction list.',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Export BankTransactions for FC.'
        get '/export' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_day
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= 3.month
            return respond_with_json("The selected date range (start_date: #{start_date_time} and end_date: #{end_date_time}) is not valid! Please select a range within 3 months.", HTTP_CODE[:NOT_ACCEPTABLE])
          end

          date_range = start_date_time..end_date_time

          bank_transactions = BankTransaction.where(transactionable_by: @current_staff.warehouse).where(created_at: date_range).includes(:transactionable_by, :credit_bank_account, transactionable_for: :aggregated_transaction_customer_orders)
          present bank_transactions, with: ShopothWarehouse::V1::Entities::BankTransactions
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch bank_transaction list due to: #{error.message}"
          error!(respond_with_json('Unable to fetch bank_transaction list.',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Details of a specific Bank Transactions for FC.'
        get '/:id' do
          bank_transaction = BankTransaction.find(params[:id])
          unless bank_transaction
            error!(respond_with_json('Bank Transaction not found', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          present bank_transaction, with: ShopothWarehouse::V1::Entities::BankTransactionDetails
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to show bank transaction details due to: #{error.message}"
          error!(respond_with_json('Unable to show bank transaction details.',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Create FC Bank Transactions to CWH.'
        params do
          optional :debit_bank_account_id, type: Integer
          requires :credit_bank_account_id, type: Integer
          requires :amount, type: BigDecimal
          optional :chalan_no, type: String
          requires :start_date_time, type: DateTime
          requires :end_date_time, type: DateTime
          optional :images_file
        end
        post do
          start_date_time = params[:start_date_time].to_datetime.utc.beginning_of_day
          end_date_time = params[:end_date_time].to_datetime.utc.at_end_of_day
          date_range = start_date_time..end_date_time
          customer_orders = @current_staff.warehouse.customer_orders.joins(:payments).where(
            "(payments.paymentable_type  = 'Route' OR payments.paymentable_type = 'Rider') AND payments.receiver_type = 'Staff'",
          ).where(payments: { created_at: date_range })

          unless customer_orders.count.positive?
            error!(respond_with_json('Customer orders not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          if params[:debit_bank_account_id].present?
            debit_bank_account = BankAccount.find_by(id: params[:debit_bank_account_id])
            unless debit_bank_account && debit_bank_account.ownerable == @current_staff.warehouse
              error!(respond_with_json('Unable to find debit bank account.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
          end

          credit_bank_account = BankAccount.find_by(id: params[:credit_bank_account_id])
          unless credit_bank_account && credit_bank_account.ownerable == Staff.finance.first.warehouse
            error!(respond_with_json('Unable to find credit bank account.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          number_of_chalan_no = params[:chalan_no].to_s.split(/\s*,\s*/).count
          number_of_image = params[:images_file]&.count || 0
          unless number_of_chalan_no == number_of_image
            error!(failure_response_with_json('Number of given chalan not matched with number of given image', HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:NOT_ACCEPTABLE])
          end

          ActiveRecord::Base.transaction do
            aggregated_transaction = AggregatedTransaction.create
            total_amount = BankTransaction.create_aggregated_transaction_customer_orders(customer_orders, aggregated_transaction)

            if total_amount == params[:amount].ceil
              warehouse = Warehouse.find_by(warehouse_type: 'central')
              BankTransaction.create!(
                debit_bank_account_id: debit_bank_account&.id,
                credit_bank_account_id: credit_bank_account.id,
                amount: total_amount,
                chalan_no: params[:chalan_no],
                images_file: params[:images_file],
                transactionable_by: @current_staff.warehouse,
                transactionable_to: warehouse,
                transactionable_for: aggregated_transaction,
                created_by_id: @current_staff.id
              )
              respond_with_json('Successfully created bank transaction.', HTTP_CODE[:CREATED])
            else
              aggregated_transaction.destroy
              respond_with_json('Total amount mismatched.', HTTP_CODE[:FORBIDDEN])
            end
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create bank transaction due to: #{error.message}"
          error!(respond_with_json('Unable to create bank transaction.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Collect agent and sub_agent commission from CWH.'
        params do
          requires :bank_transaction_id, type: Integer
          requires :transaction_type, type: String
        end
        put 'collect_commission' do
          unless %w(agent_commission sub_agent_commission).include?(params[:transaction_type])
            error!(respond_with_json('Bank transaction not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          bank_transaction = BankTransaction.find_by(id: params[:bank_transaction_id], transactionable_to: @current_staff.warehouse, is_approved: false)
          if bank_transaction.present? #&.transactionable_for&.agent_commission.present? || bank_transaction&.transactionable_for&.sub_agent_commission.present?
            bank_transaction.update!(is_approved: true)
            respond_with_json('Commission collected successfully.', HTTP_CODE[:OK])
          else
            error!(respond_with_json('Bank transaction not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to collect commission due to: #{error.message}"
          error!(respond_with_json('Unable to collect commission.', HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        route_param :id do
          before do
            @bank_transaction = BankTransaction.find_by(id: params[:id])
            unless @bank_transaction
              error!(failure_response_with_json('Bank Transaction not found.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
          end

          desc 'Get bank transaction partners margin list.'
          params do
            use :pagination, per_page: 25
            optional :skip_pagination, type: Boolean
          end
          get 'partners_margin_list' do
            order_ids = @bank_transaction.transactionable_for&.aggregated_transaction_customer_orders&.joins(customer_order: :partner_margin)&.pluck(:customer_order_id)&.compact
            customer_orders = CustomerOrder.where(id: order_ids)
            if customer_orders.empty?
              error!(respond_with_json('Customer orders not found.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
            # TODO: Need to Optimize Query
            customer_orders = if params[:skip_pagination]
                                customer_orders
                              else
                                paginate(Kaminari.paginate_array(customer_orders))
                              end

            ShopothWarehouse::V1::Entities::AggregatedTransactionPartnerMargin.represent(customer_orders)
          rescue => ex
            error! respond_with_json("Unable to fetch Aggregated Customer order list due to #{ex.message}", HTTP_CODE[:NOT_FOUND])
          end

          desc 'Get bank transaction agent commission list.'
          params do
            use :pagination, per_page: 25
            optional :skip_pagination, type: Boolean
          end
          get 'agent_commission_list' do
            order_ids = @bank_transaction.transactionable_for&.aggregated_transaction_customer_orders&.pluck(:customer_order_id)&.compact
            customer_orders = CustomerOrder.where(id: order_ids)
            if customer_orders.empty?
              error!(respond_with_json('Customer orders not found.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
            # TODO: Need to Optimize Query
            customer_orders = if params[:skip_pagination]
                                customer_orders
                              else
                                paginate(Kaminari.paginate_array(customer_orders))
                              end

            ShopothWarehouse::V1::Entities::AggregatedTransactionAgentCommission.represent(customer_orders)
          rescue => ex
            error! respond_with_json("Unable to fetch Aggregated Customer order list due to #{ex.message}",
                                     HTTP_CODE[:NOT_FOUND])
          end
        end
      end
    end
  end
end
