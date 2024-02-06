module Finance
  module V1
    module Entities
      class PurchaseOrders < Grape::Entity
        expose :id
        expose :qc_status
        expose :supplier_id
        expose :supplier_name
        expose :quantity
        expose :total_price
        expose :created_at, as: :order_date
        expose :order_status, as: :status
        expose :paid
        expose :pay_status

        def supplier_name
          object&.supplier&.supplier_name
        end

        def qc_status
          object&.line_items&.map { |line_item| line_item.qc_status }.all?(true)
        end

        def paid
          object.bank_transactions.sum(:amount)
        end

        def pay_status
          if object.bank_transactions.blank?
            'Not settled'
          elsif object.bank_transactions.sum(:amount) >= object.total_price
            'Fully settled'
          else
            'Partially settled'
          end
        end
      end
    end
  end
end
