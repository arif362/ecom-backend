# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class PurchaseOrderInvoices < ShopothWarehouse::Base
      resource :purchase_order_invoices do
        params do
          requires :purchase_order_id, type: String
        end

        desc 'create a new Purchase_Order_Invoice'
        post do
          purchase_order_invoices = PurchaseOrderInvoice.new(params)
          purchase_order_invoices if purchase_order_invoices.save!
        rescue StandardError
          error! respond_with_json('Unable to create Purchase_Order_Invoice.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Update a specific Purchase_Order_Invoice'
        route_param :id do
          put do
            purchase_order_invoices = PurchaseOrderInvoice.find(params[:id])
            purchase_order_invoices if purchase_order_invoices.update!(params)
          rescue StandardError
            error! respond_with_json('Unable to update Purchase_Order_Invoice.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Return list of Purchase_Order_Invoice'
        get do
          po_invoices = PurchaseOrderInvoice.all
          paginate(po_invoices.order(created_at: :desc))
        end

        desc 'Return a Purchase_Order_Invoice'
        params do
          requires :id, type: Integer, allow_blank: false, desc: 'Purchase_Order_Invoice id'
        end

        get ':id' do
          purchase_order_invoices = PurchaseOrderInvoice.find(params[:id])
          purchase_order_invoices if purchase_order_invoices.present?
        rescue StandardError
          error! respond_with_json('Unable to find Purchase_Order_Invoice.', HTTP_CODE[:NOT_FOUND])
        end
      end
    end
  end
end
