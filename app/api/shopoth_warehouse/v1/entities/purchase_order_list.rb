module ShopothWarehouse
  module V1
    module Entities
      class PurchaseOrderList < Grape::Entity
        expose :id
        expose :supplier_id
        expose :product_id
        expose :product_title
        expose :qc_status
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

        def product_title
          product&.title
        end

        def product_id
          product&.id
        end

        def product
          object&.line_items&.first&.variant&.product
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
