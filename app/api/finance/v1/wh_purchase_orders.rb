# frozen_string_literal: true

module Finance
  module V1
    class WhPurchaseOrders < Finance::Base
      helpers do
        def assign_wh_purchase_orders_to_line_items(entities, duplicate_sups, master_po_id)
          entities.map do |key, values|
            supplier_id = key
            total_price = 0
            total_quantity = 0
            variants = []
            line_items = values.map do |val|
              variant_id = val&.dig(:variant_id)
              duplicate_sups << supplier_id if variants.include?(variant_id)
              next if variants.include?(variant_id)

              variants << variant_id
              supplier_id = val&.dig(:supplier_id)
              quantity = val[:quantity]
              total_quantity += quantity
              price = fetch_price(variant_id, supplier_id)
              total_price += price.to_d * quantity.to_d
              initialize_line_item(price, variant_id, quantity)
            end.compact
            next if line_items.compact.blank?

            purchase_orders = create_purchase_order(supplier_id, total_price, total_quantity, master_po_id, line_items)
            save_line_items_n_assign_order(purchase_orders, line_items)
          end.flatten.compact
        end

        def create_purchase_order(supplier_id, total_price, quantity, master_po_id, line_items)
          unless supplier_id.present?
            error!(respond_with_json('Supplier must be present', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
          order = WhPurchaseOrder.new(supplier_id: supplier_id,
                                      total_price: total_price,
                                      quantity: quantity,
                                      master_po_id: master_po_id,
                                      unique_id: SecureRandom.uuid,
                                      created_by_id: @current_staff.id)
          response = call_3ps_wh_po_create(order, line_items)
          if response[:error].present?
            error!(respond_with_json("PO error response: #{response[:error_descrip]}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
          order.save!
          order
        end

        def initialize_line_item(price, variant_id, quantity)
          LineItem.new(variant_id: variant_id, quantity: quantity, price: price)
        end

        def save_line_items_n_assign_order(order, items)
          items.map do |item|
            item.update!(itemable: order)
          end
        end

        def fetch_price(variant, supplier)
          supplier_variant = SuppliersVariant.find_by(variant_id: variant, supplier_id: supplier)
          supplier_variant&.supplier_price
        end

        def call_3ps_wh_po_create(wh_purchase_order, wh_line_items)
          line_items = []
          wh_line_items.each do |line_item|
            line_items <<
              {
                product_id: line_item.variant.unique_id,
                lot_name: '0a859de3',
                qty_done: line_item.quantity,
              }
          end
          Thanos::WhPurchaseOrder.create(wh_purchase_order, line_items)
        end
      end

      resource :wh_purchase_orders do
        desc 'Get all Wh_purchase_orders for Finance.'
        params do
          use :pagination, per_page: 50
        end
        get do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= 3.month
            error!(respond_with_json("The selected date range is not valid!
                        Please select a range within 3 months.", HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
          end

          date_range = start_date_time..end_date_time
          wh_purchase_orders = WhPurchaseOrder.includes(:bank_transactions, :supplier, :line_items).
                               where(created_at: date_range)
          if wh_purchase_orders.present?
            # TODO: Need to Optimize Query
            present paginate(Kaminari.paginate_array(wh_purchase_orders.order(created_at: :desc))), with:
              Finance::V1::Entities::PurchaseOrders
          else
            []
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch WhPurchaseOrder list due to: #{error.message}"
          error!(respond_with_json('Unable to fetch WhPurchaseOrder list.',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Export all Wh_purchase_orders for Finance.'
        get '/export' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_day
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= 3.month
            error!(respond_with_json("The selected date range is not valid!
                        Please select a range within 3 months.", HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
          end

          date_range = start_date_time..end_date_time
          wh_purchase_orders = WhPurchaseOrder.where(created_at: date_range)
          if wh_purchase_orders.present?
            present wh_purchase_orders.order(created_at: :desc), with: Finance::V1::Entities::PurchaseOrders
          else
            []
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch WhPurchaseOrder list due to: #{error.message}"
          error!(respond_with_json('Unable to fetch WhPurchaseOrder list.',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Get a purchase order details for Finance.'
        get ':id' do
          purchase_order = WhPurchaseOrder.find_by(id: params[:id])
          unless purchase_order
            error!(respond_with_json('PurchaseOrder not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          present purchase_order, with: Finance::V1::Entities::PurchaseOrderDetails
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch WhPurchaseOrder due to: #{error.message}"
          error!(respond_with_json('Unable to fetch WhPurchaseOrder.',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Create a po'
        params do
          requires :wh_order_params, type: Hash do
            requires :master_po_id, type: String
            requires :variants, type: Array do
              requires :variant_id, type: Integer
              requires :supplier_id, type: Integer
              requires :quantity, type: Integer
            end
          end
        end
        post do
          entities = params.dig(:wh_order_params, :variants)
          unless entities.present?
            error!(respond_with_json('Required params not present', HTTP_CODE[:BAD_REQUEST]), HTTP_CODE[:BAD_REQUEST])
          end

          grouped_entities = entities.group_by { |entity| entity[:supplier_id] }
          duplicate_sups = []
          assign_wh_purchase_orders_to_line_items(grouped_entities, duplicate_sups, params[:wh_order_params][:master_po_id])
          respond_with_json('Successfully PO Created', HTTP_CODE[:CREATED])
        rescue StandardError => ex
          error!(respond_with_json("Unable to create line items due to: #{ex.message}.",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
