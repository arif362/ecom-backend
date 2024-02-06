module ShopothWarehouse
  module V1
    class LineItems < ShopothWarehouse::Base
      helpers do
        def assign_wh_purchase_orders_to_line_items(entities, duplicate_sups)
          purchase_orders_n_line_items = {}
          orders = []
          orders = entities.map do |key, values|
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

            purchase_orders = create_purchase_order(supplier_id, total_price, total_quantity, nil)
            items = save_line_items_n_assign_order(purchase_orders, line_items)
            order_with_supplier_name = purchase_orders.as_json.merge(fetch_supplier_name(supplier_id))
            orders << order_with_supplier_name.as_json.merge( { line_items: items }.as_json )
          end.flatten.compact
          purchase_orders_n_line_items[:wh_purchase_orders] = orders.uniq
          purchase_orders_n_line_items
        end

        def assign_dh_purchase_orders_to_line_items(entities, warehouse_id)
          purchase_orders_n_line_items = {}
          total_price = 0
          total_quantity = 0
          line_items = entities.map do |entity|
            variant_id = entity[:variant_id]
            warehouse_id = warehouse_id
            quantity = entity[:quantity]
            variant = Variant.find(variant_id)
            price = variant.price_distribution.to_d
            total_price += price * quantity.to_d
            total_quantity += quantity
            initialize_line_item(price, variant_id, quantity)
          end.flatten.compact
          purchase_order = create_purchase_order(nil, total_price, total_quantity, warehouse_id)
          items = save_line_items_n_assign_order(purchase_order, line_items)
          purchase_orders_n_line_items[:dh_purchase_order] = purchase_order.as_json.merge({ line_items: items }.as_json)
          purchase_orders_n_line_items
        end

        def create_purchase_order(supplier_id, total_price, quantity, warehouse_id)
          order = if supplier_id.present?
                    WhPurchaseOrder.new(supplier_id: supplier_id,
                                        total_price: total_price,
                                        quantity: quantity,
                                        created_by_id: @current_staff.id)
                  else
                    DhPurchaseOrder.new(warehouse_id: warehouse_id,
                                        quantity: quantity,
                                        total_price: total_price,
                                        order_date: DateTime.now,
                                        created_by_id: @current_staff.id)
                  end
          order if order.save!
        end

        def initialize_line_item(price, variant_id, quantity)
          LineItem.new(variant_id: variant_id, quantity: quantity, price: price)
        end

        def save_line_items_n_assign_order(order, items)
          items.map do |item|
            item.update!(itemable: order)
            variant_id = item.variant_id
            product(variant_id)
            item.as_json.merge({ product_id: product_id, product_title: product_title })
          end
        end

        def fetch_price(variant, supplier)
          supplier_variant = SuppliersVariant.find_by(variant_id: variant, supplier_id: supplier)
          supplier_variant&.supplier_price
        end

        def product(variant_id)
          @product = Variant.find(variant_id)&.product
        end

        def product_id
          @product&.id
        end

        def product_title
          @product&.title
        end

        def fetch_supplier_name(supplier)
          return {} unless supplier.present?

          name = Supplier.find(supplier)&.supplier_name
          { supplier_name: name }
        end
      end

      resource :line_items do
        desc 'Return list of line_items'
        get do
          line_items = LineItem.all
          paginate(line_items)
        end

        desc 'create warehouse purchase order and assign it to line items'
        params do
          requires :wh_order_params, type: Hash do
            requires :variants, type: Array
          end
        end
        post 'create_line_items_with_wh_po' do
          entities = params.dig(:wh_order_params, :variants)
          return false unless entities.present?

          grouped_entities = entities.group_by { |entity| entity[:supplier_id] }
          duplicate_sups = []
          response = assign_wh_purchase_orders_to_line_items(grouped_entities, duplicate_sups)
          if duplicate_sups.compact.present?
            suppliers = Supplier.find(duplicate_sups.compact).map(&:supplier_name)
            error! respond_with_json("duplicate variants for suppliers: #{suppliers.join(',')}",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
          else
            response
          end

        rescue StandardError => ex
          error! respond_with_json("Unable to create line items due to: #{ex.message}.",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'create distribution house purchase order and assign it to line items'
        params do
          requires :dh_order_params, type: Hash do
            requires :variants, type: Array
          end
        end
        post 'create_line_items_with_dh_po' do
          entities = params.dig(:dh_order_params, :variants)
          return false unless entities.present?

          variants = entities.map { |entity| entity[:variant_id] }
          dup_variants = variants.select { |el| variants.count(el) > 1 }.uniq
          if dup_variants.present?
            error! respond_with_json("duplicate_variants: #{dup_variants.join('-')}",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          unless check_dh_warehouse
            Rails.logger.info('Only FC can place STO')
            error!(respond_with_json('Only FC can place STO',
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          warehouse_id = @current_staff.warehouse.id
          assign_dh_purchase_orders_to_line_items(entities, warehouse_id)
        rescue StandardError => ex
          error! respond_with_json("Unable to create line items due to: #{ex.message}.",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Dh Bulk Import'
        post '/dh_bulk_import' do
          po_table = CSV.parse(File.read(params[:csv_file][:tempfile]), headers: true)
          entities = po_table.map do |po|
            po_hash = po.to_h
            {
              product: po_hash["product"],
              variant_id: po_hash["variant_id"].to_i,
              quantity: po_hash["quantity"].to_i
            }
          end
          warehouse_id = @current_staff.warehouse.id
          assign_dh_purchase_orders_to_line_items(entities, warehouse_id)
        end

        desc 'Wh Bulk Import'
        post '/wh_bulk_import' do
          po_table = CSV.parse(File.read(params[:csv_file][:tempfile]), headers: true)
          entities = po_table.map do |po|
            po_hash = po.to_h
            {
              product_id: po_hash["product_id"].to_i,
              quantity: po_hash["quantity"].to_i,
              supplier_id: po_hash["supplier_id"].to_i,
              supplier_name: po_hash["supplier_name"],
              supplier_price: po_hash["supplier_price"].to_d,
              variant_id: po_hash["variant_id"].to_i
            }
          end
          grouped_entities = entities.group_by { |entity| entity["supplier_id"] }
          assign_wh_purchase_orders_to_line_items(grouped_entities)
        end

        desc 'Details of a specific location with audit logs.'
        get ':id' do
          line_item = LineItem.find_by(id: params[:id])
          unless line_item
            error!(failure_response_with_json('Line item not found',
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end
          audit_logs = line_item.audits
          unless audit_logs
            error!(failure_response_with_json('Audit log not found',
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])

          end
          success_response_with_json('Successfully fetched audit log', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::LineItemLog.represent(
                                       audit_logs,
                                     ))

        rescue StandardError => error
          error!(failure_response_with_json("Unable to fetch location audit log due to #{error.message}",
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

      end
    end
  end
end
