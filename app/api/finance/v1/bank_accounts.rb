# frozen_string_literal: true

module Finance
  module V1
    class BankAccounts < Finance::Base
      resource :bank_accounts do
        desc 'List of Bank Accounts for finance.'
        params do
          optional :id, type: Integer
          optional :type, type: String
        end
        get do
          if params[:id].present? && params[:type].present?
            bank_accounts = BankAccount.where(ownerable_id: params[:id], ownerable_type: params[:type])
          else
            warehouse = Warehouse.find_by(warehouse_type: Warehouse::WAREHOUSE_TYPES[:central])
            bank_accounts = BankAccount.where(ownerable: warehouse)
          end

          unless bank_accounts.present?
            error!(respond_with_json('Bank accounts not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          present bank_accounts.includes(:ownerable), with: Finance::V1::Entities::BankAccounts
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch bank accounts due to: #{error.message}"
          error!(respond_with_json('Unable to fetch bank accounts.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'List of all Bank Accounts based on account_type for Finance.'
        params do
          use :pagination, per_page: 50
        end
        get '/list' do
          bank_accounts = BankAccount.all
          bank_accounts = case params[:account_type]
                          when 'warehouse'
                            bank_accounts.where(ownerable_type: 'Warehouse')
                          when 'supplier'
                            bank_accounts.where(ownerable_type: 'Supplier')
                          when 'distributor'
                            bank_accounts.where(ownerable_type: 'Distributor')
                          else
                            warehouse = Warehouse.find_by(warehouse_type: Warehouse::WAREHOUSE_TYPES[:central])
                            bank_accounts.where(ownerable: warehouse)
                          end
          # TODO: Need to Optimize Query
          present paginate(Kaminari.paginate_array(bank_accounts.includes(:ownerable))), with: Finance::V1::Entities::BankAccounts
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch bank accounts due to: #{error.message}"
          error!(respond_with_json('Unable to fetch bank accounts.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
