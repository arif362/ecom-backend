# frozen_string_literal: true

module Finance
  module V1
    class BankTransactions < Finance::Base
      resource :bank_transactions do
        desc 'List of Bank Transactions for Finance Admin.'
        params do
          use :pagination, per_page: 50
          optional :distributor_id, type: Integer
          optional :start_date_time, type: DateTime
          optional :end_date_time, type: DateTime
        end
        get do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_day
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= 3.month
            return respond_with_json("The selected date range (start_date: #{start_date_time} and end_date: #{end_date_time}) is not valid! Please select a range within 3 months.", HTTP_CODE[:NOT_ACCEPTABLE])
          end

          date_range = start_date_time..end_date_time
          bank_transactions = BankTransaction.where(transactionable_to: @current_staff.warehouse, created_at: date_range)
          if params[:distributor_id].present?
            distributor = Distributor.find_by(id: params[:distributor_id])
            unless distributor
              error!(respond_with_json('Unable to find distributor.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end

            bank_transactions = bank_transactions.where(transactionable_by: distributor)
          end

          bank_transactions = bank_transactions.includes(:transactionable_by, :credit_bank_account, :debit_bank_account, :transactionable_for)
          # TODO: Need to Optimize Query
          Finance::V1::Entities::BankTransactions.represent(
            paginate(Kaminari.paginate_array(bank_transactions.order(id: :desc))),
          )
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch bank transactions due to: #{error.message}"
          error!(respond_with_json('Unable to fetch bank transactions.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Export Bank Transactions for Finance Admin.'
        get '/export' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_day
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= 3.month
            return respond_with_json("The selected date range (start_date: #{start_date_time} and end_date: #{end_date_time}) is not valid! Please select a range within 3 months.", HTTP_CODE[:NOT_ACCEPTABLE])
          end

          date_range = start_date_time..end_date_time
          bank_transactions = BankTransaction.where(transactionable_to: @current_staff.warehouse, created_at: date_range)
          if params[:distributor_id].present?
            distributor = Distributor.find_by(id: params[:distributor_id])
            unless distributor
              error!(respond_with_json('Unable to find distributor.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end

            bank_transactions = bank_transactions.where(transactionable_by: distributor)
          end

          bank_transactions = bank_transactions.includes(:transactionable_by, :credit_bank_account, :debit_bank_account, :transactionable_for)
          Finance::V1::Entities::BankTransactions.represent(bank_transactions.order(id: :desc))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to export bank transactions due to: #{error.message}"
          error!(respond_with_json('Unable to export bank transactions.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'List of Commission Bank Transactions for Finance Admin.'
        params do
          use :pagination, per_page: 50
          requires :month, type: Integer
          requires :year, type: Integer
          optional :distributor_id, type: Integer
          optional :transaction_type, type: Integer
        end
        get 'commissions' do
          start_date_time = DateTime.civil(params[:year], params[:month], 1).in_time_zone('Dhaka').beginning_of_day
          end_date_time = DateTime.civil(params[:year], params[:month], -1).in_time_zone('Dhaka').end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= (3.month + 1.day)
            error!(respond_with_json("The selected date range (start_date: #{start_date_time} and end_date: #{end_date_time}) is not valid! Please select a range within 3 months.",
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          date_range = start_date_time..end_date_time
          bank_transactions = if params[:transaction_type].present?
                                unless [1, 2].include?(params[:transaction_type])
                                  error!(respond_with_json('Please provide a valid transaction_type.',
                                                           HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
                                end
                                BankTransaction.joins("INNER JOIN aggregated_transactions ON bank_transactions.transactionable_for_id = aggregated_transactions.id AND bank_transactions.transactionable_for_type = 'AggregatedTransaction'").where(aggregated_transactions: { transaction_type: params[:transaction_type] }, created_at: date_range)
                              else
                                BankTransaction.joins("INNER JOIN aggregated_transactions ON bank_transactions.transactionable_for_id = aggregated_transactions.id AND bank_transactions.transactionable_for_type = 'AggregatedTransaction'").where(aggregated_transactions: { transaction_type: [1, 2] }, created_at: date_range)
                              end

          if params[:distributor_id].present?
            distributor = Distributor.find_by(id: params[:distributor_id])
            unless distributor
              error!(respond_with_json('Unable to find distributor.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end

            bank_transactions = bank_transactions.where(transactionable_to: distributor)
          end

          bank_transactions = bank_transactions.includes(:transactionable_to, :credit_bank_account, :debit_bank_account, :transactionable_for)
          # TODO: Need to Optimize Query
          Finance::V1::Entities::AgentBankTransaction.represent(
            paginate(Kaminari.paginate_array(bank_transactions)),
          )
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch commissions due to: #{error.message}"
          error!(respond_with_json('Unable to fetch commissions.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'List of Supplier Payment for Finance Admin.'
        params do
          use :pagination, per_page: 50
          optional :supplier_id, type: Integer
          optional :start_date_time, type: DateTime
          optional :end_date_time, type: DateTime
        end
        get '/get_supplier_payment' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_day
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= 3.month
            return respond_with_json("The selected date range (start_date: #{start_date_time} and end_date: #{end_date_time}) is not valid! Please select a range within 3 months.", HTTP_CODE[:NOT_ACCEPTABLE])
          end

          date_range = start_date_time..end_date_time
          bank_transactions = BankTransaction.where(transactionable_to_type: 'Supplier', transactionable_for_type: 'WhPurchaseOrder', created_at: date_range)
          if params[:supplier_id].present?
            supplier = Supplier.find_by(id: params[:supplier_id])
            unless supplier
              error!(respond_with_json('Unable to find Supplier.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end

            bank_transactions = bank_transactions.where(transactionable_to: supplier)
          end

          bank_transactions = bank_transactions.includes(:transactionable_to, :credit_bank_account, :debit_bank_account)
          # TODO: Need to Optimize Query
          Finance::V1::Entities::SupplierPayments.represent(paginate(Kaminari.paginate_array(bank_transactions)))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch supplier payments due to: #{error.message}"
          error!(respond_with_json('Unable to fetch supplier payments.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Export Supplier Payments for Finance Admin.'
        get '/export_supplier_payment' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_day
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= 3.month
            return respond_with_json("The selected date range (start_date: #{start_date_time} and end_date: #{end_date_time}) is not valid! Please select a range within 3 months.", HTTP_CODE[:NOT_ACCEPTABLE])
          end

          date_range = start_date_time..end_date_time

          bank_transactions = BankTransaction.where(transactionable_to_type: 'Supplier', transactionable_for_type: 'WhPurchaseOrder', created_at: date_range)
          if params[:supplier_id].present?
            supplier = Supplier.find_by(id: params[:supplier_id])
            unless supplier
              error!(respond_with_json('Unable to find Supplier.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end

            bank_transactions = bank_transactions.where(transactionable_to: supplier)
          end

          bank_transactions = bank_transactions.includes(:transactionable_to, :credit_bank_account, :debit_bank_account)
          Finance::V1::Entities::SupplierPayments.represent(bank_transactions)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to export Supplier payments due to: #{error.message}"
          error!(respond_with_json('Unable to export Supplier payments.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Get details of a specific Bank Transactions for Finance.'
        get '/:id' do
          bank_transaction = BankTransaction.find_by(id: params[:id])
          unless bank_transaction
            error!(respond_with_json('Bank Transaction not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          Finance::V1::Entities::BankTransactionDetails.represent(bank_transaction)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch bank transaction details due to: #{error.message}"
          error!(respond_with_json('Unable to fetch bank transaction details.',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Pay supplier payments for Finance Admin.'
        params do
          requires :debit_bank_account_id, type: Integer
          requires :credit_bank_account_id, type: Integer
          requires :purchase_order_id, type: Integer
          requires :amount, type: Integer
          requires :chalan_no, type: String
          optional :image_file
        end
        post '/supplier_payment' do
          unless params[:amount].positive?
            error!(respond_with_json('Please provide valid amount.', HTTP_CODE[:FORBIDDEN]),
                   HTTP_CODE[:FORBIDDEN])
          end

          debit_bank_account = BankAccount.find_by(id: params[:debit_bank_account_id])
          credit_bank_account = BankAccount.find_by(id: params[:credit_bank_account_id])
          unless debit_bank_account && credit_bank_account
            error!(respond_with_json('Unable to find bank account.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          po_order = WhPurchaseOrder.find_by(id: params[:purchase_order_id])
          unless po_order
            error!(respond_with_json('Unable to find Purchase Order.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          paid_amount = po_order.bank_transactions.sum(:amount)
          if po_order.total_price <= paid_amount
            error!(respond_with_json('There is no due for this Purchase Order.', HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:NOT_ACCEPTABLE])
          end

          if params[:amount] > (po_order.total_price - paid_amount)&.ceil
            error!(respond_with_json("You can't pay more than purchase order's price.",
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
          end

          BankTransaction.create!(
            debit_bank_account_id: debit_bank_account.id,
            credit_bank_account_id: credit_bank_account.id,
            amount: params[:amount]&.ceil,
            chalan_no: params[:chalan_no],
            image_file: params[:image_file],
            transactionable_by: @current_staff.warehouse,
            transactionable_to: po_order.supplier,
            transactionable_for: po_order,
          )
          respond_with_json('Successfully created supplier payment.', HTTP_CODE[:CREATED])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create supplier payment due to: #{error.message}"
          error!(respond_with_json('Unable to create supplier payment.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Pay pending commission and margin to DH.'
        params do
          requires :distributor_id, type: Integer
          requires :month, type: Integer
          requires :year, type: Integer
          requires :debit_bank_account_id, type: Integer
          requires :credit_bank_account_id, type: Integer
          requires :chalan_no, type: String
          requires :transaction_type, type: String
          requires :image_file
        end
        post '/pay_commission' do
          start_date = DateTime.civil(params[:year], params[:month], 1).in_time_zone('Dhaka').beginning_of_day
          end_date = DateTime.civil(params[:year], params[:month], -1).in_time_zone('Dhaka').end_of_day
          unless %w(agent_commission sub_agent_commission).include?(params[:transaction_type])
            error!(respond_with_json('Please provide a valid transaction type.', HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:NOT_ACCEPTABLE])
          end

          date_range = start_date..end_date
          db_bank_account = BankAccount.find_by(id: params[:debit_bank_account_id])
          cr_bank_account = BankAccount.find_by(id: params[:credit_bank_account_id])
          unless db_bank_account && cr_bank_account
            error!(respond_with_json('Unable to find bank account.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          distributor = Distributor.find_by(id: params[:distributor_id])
          unless distributor
            error!(respond_with_json('Unable to find distributor.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          ActiveRecord::Base.transaction do
            aggregated_transaction = AggregatedTransaction.create!(
              transaction_type: params[:transaction_type], month: params[:month], year: params[:year],
            )
            statuses = OrderStatus.fetch_statuses(%w(completed partially_returned))
            amount = case params[:transaction_type]
                     when 'agent_commission'
                       BankTransaction.create_aggregated_agent_commission(distributor, date_range, aggregated_transaction, statuses, @current_staff)
                     when 'sub_agent_commission'
                       BankTransaction.create_aggregated_sub_agent_commission(distributor, date_range, aggregated_transaction, statuses)
                     else
                       { total_amount: 0, partners_margin: 0 }
                     end

            unless amount[:partners_margin].positive?
              aggregated_transaction.destroy
              error!(respond_with_json('Payment amount not positive.', HTTP_CODE[:FORBIDDEN]),
                     HTTP_CODE[:FORBIDDEN])
            end

            warehouse = Warehouse.find_by(warehouse_type: 'central')
            aggregated_transaction.update(
              total_amount: amount[:total_amount],
              transactional_amount: amount[:partners_margin],
              adjustment_amount: amount[:partners_margin] - amount[:total_amount],
            )

            BankTransaction.create!(
              debit_bank_account: db_bank_account,
              credit_bank_account: cr_bank_account,
              amount: amount[:partners_margin],
              chalan_no: params[:chalan_no],
              images_file: [params[:image_file]],
              transactionable_by: warehouse,
              transactionable_to: distributor,
              transactionable_for: aggregated_transaction,
            )
            status :created
            { message: 'Successfully created bank transaction.', status_code: HTTP_CODE[:CREATED] }
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create bank transaction due to: #{error.full_message}"
          error!(respond_with_json("Unable to create bank transaction due to: #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Receive Bank Transaction.'
        put '/receive/:id' do
          bank_transaction = BankTransaction.find_by(id: params[:id], transactionable_to: @current_staff.warehouse, is_approved: false)
          unless bank_transaction
            error!(respond_with_json('Bank Transaction not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          bank_transaction.update!(is_approved: true, finance_received_at: Time.now)
          respond_with_json('Successfully approved bank transaction.', HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to approve bank transaction due to: #{error.message}"
          error!(respond_with_json('Unable to approve bank transaction.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        route_param :id do
          before do
            @bank_transaction = BankTransaction.find_by(id: params[:id])
            unless @bank_transaction
              error!(respond_with_json('Bank Transaction not found.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
          end

          desc 'Get partners margins for Finance.'
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

            Finance::V1::Entities::AggregatedTransactionPartnerMargin.represent(customer_orders)
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to fetch partner margins due to: #{error.message}"
            error!(respond_with_json('Unable to fetch partner margins.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          desc 'Get agent commissions for Finance.'
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

            customer_orders = if params[:skip_pagination]
                                customer_orders
                              else
                                paginate(Kaminari.paginate_array(customer_orders))
                              end

            Finance::V1::Entities::AggregatedTransactionAgentCommission.represent(customer_orders)
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to fetch agent commissions due to: #{error.message}"
            error!(respond_with_json('Unable to fetch agent commissions.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end
        end
      end
    end
  end
end
