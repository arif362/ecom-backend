# frozen_string_literal: true

module ShopothDistributor
  module V1
    class BankAccounts < ShopothDistributor::Base
      resource :bank_accounts do
        desc 'Get all Bank Accounts for DH panel.'
        params do
          optional :id, type: Integer
          optional :type, type: String
        end
        get do
          bank_accounts = if params[:id].present? && params[:type].present?
                            BankAccount.where(ownerable_id: params[:id], ownerable_type: params[:type])
                          else
                            warehouse = Warehouse.find_by(warehouse_type: Warehouse::WAREHOUSE_TYPES[:central])
                            BankAccount.where(ownerable: warehouse)
                          end

          if bank_accounts.empty?
            error!(respond_with_json('Bank accounts not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          response = ShopothWarehouse::V1::Entities::BankAccounts.represent(bank_accounts)
          success_response_with_json('Successfully fetched bank accounts.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch bank accounts due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch bank accounts.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
