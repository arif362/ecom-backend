module Finance
  module V1
    module Entities
      class SupplierPayments < Grape::Entity
        expose :id
        expose :chalan_no
        expose :created_at
        expose :supplier_name
        expose :transactionable_to_id, as: :supplier_id
        expose :amount
        expose :credit_bank_name
        expose :credit_bank_branch_name
        expose :debit_bank_name
        expose :debit_bank_branch_name

        def supplier_name
          object.transactionable_to&.supplier_name
        end

        def credit_bank_name
          object.credit_bank_account&.bank_name
        end

        def credit_bank_branch_name
          object.credit_bank_account&.branch_name
        end

        def debit_bank_name
          object.debit_bank_account&.bank_name
        end

        def debit_bank_branch_name
          object.debit_bank_account&.branch_name
        end
      end
    end
  end
end
