# frozen_string_literal: true

module ShopothDistributor
  module V1
    class BankTransactions < ShopothDistributor::Base
      resource :bank_transactions do
        desc 'Get all BankTransactions for DH panel.'
        params do
          use :pagination, per_page: 50
          optional :start_date_time, type: DateTime
          optional :end_date_time, type: DateTime
          optional :skip_pagination, type: Boolean
        end
        get do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.end_of_month
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= (3.month + 1.day)
            error!(failure_response_with_json('The selected date range is not valid! Please select a range within 3 months.',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          date_range = start_date_time..end_date_time
          bank_transactions = BankTransaction.where(transactionable_by: @current_distributor, created_at: date_range).includes(:transactionable_by, :credit_bank_account, :debit_bank_account, :transactionable_for)
          bank_transactions = if params[:skip_pagination]
                                bank_transactions.order(id: :desc)
                              else
                                paginate(Kaminari.paginate_array(bank_transactions.order(id: :desc)))
                              end

          response = ShopothWarehouse::V1::Entities::BankTransactions.represent(bank_transactions)
          success_response_with_json('Successfully fetched bank transactions.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch bank transactions due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch bank transactions.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'List of Commission Bank Transactions for DH panel.'
        params do
          use :pagination, per_page: 50
          requires :month, type: Integer
          requires :year, type: Integer
          optional :transaction_type, type: Integer
        end
        get '/commissions' do
          start_date_time = DateTime.civil(params[:year], params[:month], 1).in_time_zone('Dhaka').beginning_of_day
          end_date_time = DateTime.civil(params[:year], params[:month], -1).in_time_zone('Dhaka').end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= (3.month + 1.day)
            error!(failure_response_with_json('The selected date range is not valid! Please select a range within 3 months.',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          date_range = start_date_time..end_date_time
          bank_transactions = if params[:transaction_type].present?
                                unless [1, 2].include?(params[:transaction_type])
                                  error!(respond_with_json('Please provide a valid transaction_type.',
                                                           HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
                                end
                                BankTransaction.joins("INNER JOIN aggregated_transactions ON bank_transactions.transactionable_for_id = aggregated_transactions.id AND bank_transactions.transactionable_for_type = 'AggregatedTransaction'").where(aggregated_transactions: { transaction_type: params[:transaction_type] }, created_at: date_range, transactionable_to: @current_distributor)
                              else
                                BankTransaction.joins("INNER JOIN aggregated_transactions ON bank_transactions.transactionable_for_id = aggregated_transactions.id AND bank_transactions.transactionable_for_type = 'AggregatedTransaction'").where(aggregated_transactions: { transaction_type: [1, 2] }, created_at: date_range, transactionable_to: @current_distributor)
                              end

          bank_transactions = bank_transactions.includes(:transactionable_to, :credit_bank_account, :debit_bank_account, :transactionable_for)
          response = ShopothWarehouse::V1::Entities::AgentBankTransaction.represent(
            paginate(Kaminari.paginate_array(bank_transactions)),
          )
          success_response_with_json('Successfully fetched commissions.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch commissions due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch commissions.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        route_param :id do
          before do
            @bank_transaction = BankTransaction.find_by(id: params[:id])
            unless @bank_transaction && (@bank_transaction.transactionable_by == @current_distributor || @bank_transaction.transactionable_to == @current_distributor)
              error!(failure_response_with_json('Bank Transaction not found.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:OK])
            end
          end

          desc 'Details of a specific Bank Transactions for DH panel.'
          get do
            response = ShopothWarehouse::V1::Entities::BankTransactionDetails.represent(@bank_transaction)
            success_response_with_json('Successfully fetched bank transaction details.', HTTP_CODE[:OK], response)
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to fetch bank transactions details due to: #{error.message}"
            error!(failure_response_with_json('Unable to fetch bank transactions details.',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          desc 'Get partner margins for DH panel.'
          params do
            use :pagination, per_page: 25
            optional :skip_pagination, type: Boolean
          end
          get '/partner_margins' do
            order_ids = @bank_transaction.transactionable_for&.aggregated_transaction_customer_orders&.joins(customer_order: :partner_margin)&.pluck(:customer_order_id)&.compact
            customer_orders = CustomerOrder.where(id: order_ids)
            if customer_orders.empty?
              error!(failure_response_with_json('Customer orders not found.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:OK])
            end

            customer_orders = if params[:skip_pagination]
                                customer_orders
                              else
                                paginate(Kaminari.paginate_array(customer_orders))
                              end

            response = ShopothWarehouse::V1::Entities::AggregatedTransactionPartnerMargin.represent(customer_orders)
            success_response_with_json('Successfully fetched partner margins.', HTTP_CODE[:OK], response)
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to fetch partner margins due to: #{error.message}"
            error!(failure_response_with_json('Unable to fetch partner margins.',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          desc 'Get agent commissions for DH panel.'
          params do
            use :pagination, per_page: 25
            optional :skip_pagination, type: Boolean
          end
          get '/agent_commissions' do
            order_ids = @bank_transaction.transactionable_for&.aggregated_transaction_customer_orders&.pluck(:customer_order_id)&.compact
            customer_orders = CustomerOrder.where(id: order_ids)
            if customer_orders.empty?
              error!(failure_response_with_json('Customer orders not found.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:OK])
            end

            customer_orders = if params[:skip_pagination]
                                customer_orders
                              else
                                paginate(Kaminari.paginate_array(customer_orders))
                              end

            response = ShopothWarehouse::V1::Entities::AggregatedTransactionAgentCommission.represent(customer_orders)
            success_response_with_json('Successfully fetched agent commissions.', HTTP_CODE[:OK], response)
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to fetch agent commissions due to: #{error.message}"
            error!(failure_response_with_json('Unable to fetch agent commissions.',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
        end

        desc 'Create DH Bank Transactions to Finance.'
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
          end_date_time = params[:end_date_time].to_datetime.utc.end_of_day
          date_range = start_date_time..end_date_time
          customer_orders = @current_distributor.customer_orders.joins(:payments).where(
            payments: { paymentable_type: %w(Route Rider), receiver_type: 'Staff', created_at: date_range },
          )

          unless customer_orders.size.positive?
            error!(failure_response_with_json('Customer orders not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          debit_bank_account = nil
          if params[:debit_bank_account_id].present?
            debit_bank_account = @current_distributor.bank_accounts.find_by(id: params[:debit_bank_account_id])
            unless debit_bank_account
              error!(failure_response_with_json('Unable to find debit bank account.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:OK])
            end
          end

          credit_bank_account = BankAccount.find_by(id: params[:credit_bank_account_id])
          unless credit_bank_account&.ownerable&.staffs&.finance.present?
            error!(failure_response_with_json('Unable to find credit bank account.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          number_of_chalan_no = params[:chalan_no].to_s.split(/\s*,\s*/).count
          number_of_image = params[:images_file]&.count || 0
          unless number_of_chalan_no == number_of_image
            error!(failure_response_with_json('Number of given chalan not matched with number of given image',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          ActiveRecord::Base.transaction do
            aggregated_transaction = AggregatedTransaction.create
            total_amount = BankTransaction.create_aggregated_transaction_customer_orders(customer_orders, aggregated_transaction)
            unless total_amount == params[:amount].ceil
              aggregated_transaction.destroy
              error!(failure_response_with_json('Total amount mismatched.', HTTP_CODE[:FORBIDDEN]),
                     HTTP_CODE[:OK])
            end

            warehouse = Warehouse.find_by(warehouse_type: 'central')
            BankTransaction.create!(
              debit_bank_account_id: debit_bank_account&.id,
              credit_bank_account_id: credit_bank_account.id,
              amount: total_amount,
              chalan_no: params[:chalan_no],
              images_file: params[:images_file],
              transactionable_by: @current_distributor,
              transactionable_to: warehouse,
              transactionable_for: aggregated_transaction,
            )
            success_response_with_json('Successfully created bank transaction.', HTTP_CODE[:CREATED])
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create bank transaction due to: #{error.message}"
          error!(failure_response_with_json('Unable to create bank transaction.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Collect agent and sub_agent commission from Finance on DH panel.'
        params do
          requires :bank_transaction_id, type: Integer
          requires :transaction_type, type: String
        end
        put 'collect_commission' do
          unless %w(agent_commission sub_agent_commission).include?(params[:transaction_type].parameterize.underscore)
            error!(failure_response_with_json('Please select valid transaction type.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          bank_transaction = BankTransaction.find_by(id: params[:bank_transaction_id], transactionable_to: @current_distributor, is_approved: false)
          unless bank_transaction
            error!(failure_response_with_json('Bank transaction not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          bank_transaction.update!(is_approved: true)
          success_response_with_json('Commission collected successfully.', HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to collect commission due to: #{error.message}"
          error!(failure_response_with_json('Unable to collect commission.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end
      end
    end
  end
end
