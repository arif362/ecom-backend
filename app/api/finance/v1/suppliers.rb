# frozen_string_literal: true

module Finance
  module V1
    class Suppliers < Finance::Base
      helpers do
        def product_attribute_values(variant)
          variant.product_attribute_values.map do |attr_val|
            { value: attr_val.value }
          end
        end
      end
      resource :suppliers do
        desc 'List of Suppliers for finance.'
        params do
          use :pagination, per_page: 50
        end
        get do
          # TODO: Need to Optimize Query
          suppliers = if params[:name]
                        paginate(Kaminari.paginate_array(Supplier.search_by_name(params[:name]).
                          order(created_at: :desc)))
                      else
                        paginate(Kaminari.paginate_array(Supplier.order(created_at: :desc)))
                      end

          unless suppliers
            error!(respond_with_json('Suppliers not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          present suppliers, with: Finance::V1::Entities::Suppliers
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch Supplier list due to: #{error.message}"
          error!(respond_with_json('Unable to fetch Supplier list.',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        route_param :id do
          resource :suppliers_variants do
            desc "Finance: Return a specific Supplier's variants."
            get do
              @suppliers_variants = SuppliersVariant.where(supplier_id: params[:id])
              hash ||= []
              @suppliers_variants.each do |sv|
                variant = sv.variant
                found = hash.detect { |x| x['product'] == variant.product&.title }
                if found.present?
                  found['variants'] << {
                    'id' => variant.id,
                    'name' => variant.sku,
                    'sp_price' => sv.supplier_price,
                    'product_attribute_values' => product_attribute_values(variant),
                  }
                else
                  hash << {
                    'product' => Product.unscoped.find_by(id: variant.product_id, is_deleted: false)&.title,
                    'variants' => [
                      {
                        'id' => variant.id,
                        'name' => variant.sku,
                        'sp_price' => sv.supplier_price,
                        'product_attribute_values' => product_attribute_values(variant),
                      },
                    ],
                  }
                end
              rescue => error
                Rails.logger.info "suppliers variant fetch failed for #{sv.id} #{error.message}"
                next
              end
              hash
            rescue StandardError => error
              Rails.logger.error "\n#{__FILE__}\nUnable to fetch suppliers_variants due to: #{error.message}"
              error!(respond_with_json('Unable to fetch suppliers_variants.',
                                       HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end

            params do
              requires :suppliers_variants, type: Array do
                requires :variant_id, type: Integer
                requires :supplier_price, type: BigDecimal
              end
            end
            desc 'Finance: Bulk create a specific suppliers_variant.'
            post do
              supplier = Supplier.find_by(id: params[:id])
              unless supplier
                error!(respond_with_json('Unable to find supplier.', HTTP_CODE[:NOT_FOUND]),
                       HTTP_CODE[:NOT_FOUND])
              end

              supplier.suppliers_variants.create!(params[:suppliers_variants])
              respond_with_json('Successfully created supplier variants.', HTTP_CODE[:CREATED])
            rescue StandardError => error
              Rails.logger.error "\n#{__FILE__}\n Unable to create supplier variant due to: #{error.message}"
              error!(respond_with_json('Unable to create supplier variant.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end

            desc 'Finance: Bulk update a specific suppliers_variant.'
            put do
              params[:suppliers_variants].each do |val|
                suppliers_variant = SuppliersVariant.find_by(supplier_id: params[:id], variant_id: val[:variant_id])
                unless suppliers_variant
                  error!(respond_with_json('Unable to find suppliers_variant.', HTTP_CODE[:NOT_FOUND]),
                         HTTP_CODE[:NOT_FOUND])
                end

                suppliers_variant.update!(supplier_price: val[:supplier_price])
              end
              respond_with_json('Successfully updated supplier variants.', HTTP_CODE[:OK])
            rescue StandardError => error
              Rails.logger.error "\n#{__FILE__}\n Unable to update supplier variant due to: #{error.message}"
              error!(respond_with_json('Unable to update supplier variant.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end

            desc 'Finance: Delete a product for a specific supplier.'
            params do
              requires :variant_id, type: Integer
            end
            delete do
              item = SuppliersVariant.find_by!(supplier_id: params[:id], variant_id: params[:variant_id])
              line_item = item.supplier.wh_purchase_orders.joins(:line_items).where(
                'line_items.variant_id = ?', item.variant_id
              )
              if line_item.empty?
                respond_with_json('Successfully deleted', HTTP_CODE[:OK]) if item.destroy!
              else
                status :unprocessable_entity
                respond_with_json('PO of requested item exists under this supplier',
                                  HTTP_CODE[:UNPROCESSABLE_ENTITY])
              end
            rescue StandardError => error
              Rails.logger.error "\n#{__FILE__}\n Unable to delete supplier variant due to: #{error.message}"
              error!(respond_with_json('Unable to delete supplier variant.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          end
        end
      end
    end
  end
end
