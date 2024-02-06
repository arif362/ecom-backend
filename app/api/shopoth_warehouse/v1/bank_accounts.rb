# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class BankAccounts < ShopothWarehouse::Base
      resource :bank_accounts do
        desc 'Get all Bank Accounts for FC.'
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

          if bank_accounts.empty?
            error!(respond_with_json('Bank accounts not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          ShopothWarehouse::V1::Entities::BankAccounts.represent(bank_accounts)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch bank_account list due to: #{error.message}"
          error!(respond_with_json('Unable to fetch bank_account list.',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
