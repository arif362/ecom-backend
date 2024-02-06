# frozen_string_literal: true

module ShopothWarehouse
  module V1
    module Entities
      class PurchaseOrders < Grape::Entity
        expose :wh_purchase_order do
          expose :id
          expose :po
          expose :supplier_id
          expose :supplier_name
          expose :quantity
          expose :total_price
          expose :vat
          expose :total_price_with_vat
          expose :price_in_words
          expose :created_at, as: :order_date
          expose :qc_status
          expose :supplier_email
          expose :bin
          expose :attn
          expose :po_raised_from
          expose :supplier_group
          expose :company_address
          expose :payment_terms
          expose :contact_person
          expose :ship_to
          expose :bill_to
          expose :issued_by
          expose :order_status
          expose :paid
          expose :pay_status
          expose :master_po_id
          # expose :line_items, using: ShopothWarehouse::V1::Entities::LineItems::ItemWithLocations
          expose :line_items do |purchase_order, options|
            ShopothWarehouse::V1::Entities::LineItems::ItemWithLocations.represent(
              purchase_order.line_items, warehouse: options[:warehouse]
            )
          end
          expose :created_by
        end

        def po
          "#{object.created_at.strftime('%Y%m%d')}OPS#{object.id.to_s.rjust(6, '0')}"
        end

        def order_status
          order_status = object.order_status
          order_status == 'received_to_dh' ? 'Received' : order_status.humanize
        end

        def qc_status
          object&.line_items&.map { |line_item| line_item.qc_status }.all?(true)
        end

        def supplier_id
          supplier&.id if object.is_a?(WhPurchaseOrder)
        end

        def supplier_name
          supplier&.supplier_name if object.is_a?(WhPurchaseOrder)
        end

        def supplier_email
          supplier&.email
        end

        def attn
          supplier&.supplier_representative
        end

        def bin
          supplier&.bin
        end

        def po_raised_from
          'Operation Team(Sourcing)'
        end

        def supplier_group
          'Supplier'
        end

        def company_address
          supplier&.address_line
        end

        def payment_terms
          if object.class == WhPurchaseOrder::PO_TYPE[:wh]
            if supplier.pre_payment
              'AP'
            elsif supplier.post_payment
              'POD'
            elsif supplier.credit_payment
              'PAD'
            end
          end
        end

        def pad
          "#{supplier.credit_payment}(#{supplier.credit_days})"
        end

        def contact_person
          {
            name: 'Raisa Fareen',
            email: 'raisa.fareen@agami.ltd',
          }
        end

        def ship_to
          {
            holding: supplier_name,
            address: company_address,
            attn: 'sawmik.islam@agami.ltd',
          }
        end

        def bill_to
          {
            holding: 'AGAMI Limited',
            address_line1: 'Level-8, SKS Tower',
            address_line2: '7 VIP Road, Mohakhali',
            address_line3: 'Dhaka-1206',
            attn: 'Sarajit Baral',
            vat_id: '003279334-0203',
          }
        end

        def issued_by
          {
            name: 'Sarajit Baral',
            designation: 'Chief Executive Officer',
            holding: 'Agami Limited',
            email: 'sarajit.baral@agami.ltd',
          }
        end

        def total_price_with_vat
          @total_price_with_vat ||= begin
            total_price = object.total_price
            total_price + total_price * 0.15
          end
        end

        def price_in_words
          "#{total_price_with_vat.humanize} taka only"
        end

        def vat
          '15%'
        end

        def supplier
          object.supplier if object.is_a?(WhPurchaseOrder)
        end

        def paid
          object&.bank_transactions&.sum(:amount) if object.class.to_s == 'WhPurchaseOrder'
        end

        def pay_status
          return if object.class.to_s == 'DhPurchaseOrder'

          if object.bank_transactions.blank?
            'Not settled'
          elsif object.bank_transactions.sum(:amount) >= object.total_price
            'Fully settled'
          else
            'Partially settled'
          end
        end

        def created_by
          {
            id: object.created_by_id,
            name: Staff.unscoped.find_by(id: object.created_by_id)&.name,
          }
        end
      end
    end
  end
end
