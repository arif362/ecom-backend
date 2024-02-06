module ShopothWarehouse
  module V1
    class Bundles < ShopothWarehouse::Base
      resources :bundles do
        desc 'List all bundle products'
        route_setting :authentication, optional: true
        get '/products' do
          bundle_products = Product.bundle_product
          present bundle_products,
                  with: ShopothWarehouse::V1::Entities::ProductList
        end

        desc 'List of all packed bundle variants.'
        params do
          use :pagination, per_page: 50
        end
        get '/packed_variants' do
          variants = Variant.joins(:bundle, :warehouse_variants).where(
            "warehouse_variants.available_quantity > 0 AND warehouse_variants.warehouse_id = #{@current_staff.warehouse_id}",
          ).uniq
          response = ShopothWarehouse::V1::Entities::PackedVariants.represent(
            variants, warehouse: @current_staff.warehouse
          )
          success_response_with_json('Successfully fetched packed variants.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch packed variants due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch packed variants.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Search bundle variants.'
        get '/search' do
          search_string = params[:search_string].present? ? params[:search_string].downcase : ''
          variants = Variant.bundle_sku_search(
            search_string, Product.unscoped.bundle_product.where(is_deleted: false).ids
          ).includes(:warehouse_variants, :product, :product_attribute_values, suppliers_variants: :supplier)
          response_variants = ShopothWarehouse::V1::Entities::Bundles.represent(
            variants.limit(20), warehouse: @current_staff.warehouse
          )
          success_response_with_json('Successfully fetched variants.', HTTP_CODE[:OK],
                                     { item_count: variants.count, variants: response_variants })
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch variants due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch variants.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        desc 'Bundle variant details.'
        get '/variants/:id' do
          variant = Variant.joins(:bundle).find_by(id: params[:id])
          unless variant
            error!(failure_response_with_json('Bundle variant not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          data = ShopothWarehouse::V1::Entities::Bundles.represent(
            variant, warehouse: @current_staff.warehouse
          )
          success_response_with_json('Successfully fetched bundle details.', HTTP_CODE[:OK], data)
        rescue StandardError => error
          error!(failure_response_with_json("Unable to fetch bundle due to #{error.message}",
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Pack a bundle product.'
        params do
          requires :bundle_variant_id, type: Integer
          requires :bundle_location_id, type: Integer
          requires :bundle_quantity, type: Integer
          requires :bundle_variants, type: Array do
            requires :variant_id, type: Integer
            requires :packed_quantity, type: Integer
            requires :location_id, type: Integer
            requires :qr_code, type: String
          end
        end

        post '/pack' do
          bm = BundleManagement::BundleProduct.new
          bm.pack(declared(params).merge(current_wh: @current_staff.warehouse))
          success_response_with_json('Successfully packed bundle product.', HTTP_CODE[:OK])
        rescue BundleManagement::NotFoundError => error
          error!(failure_response_with_json(error.message, HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        rescue BundleManagement::UnacceptableError => error
          error!(failure_response_with_json(error.message, HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_ACCEPTABLE])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to pack bundle variant due to: #{error.message}"
          error!(failure_response_with_json('Unable to pack bundle variant', HTTP_CODE[:FORBIDDEN]),
                 HTTP_CODE[:FORBIDDEN])
        end

        desc 'Unpack a bundle product.'
        params do
          requires :bundle_variant_id, type: Integer
          requires :bundle_location_id, type: Integer
          requires :bundle_quantity, type: Integer
          requires :bundle_variants, type: Array do
            requires :variant_id, type: Integer
            requires :packed_quantity, type: Integer
            requires :location_id, type: Integer
            requires :qr_code, type: String
          end
        end

        post '/un_pack' do
          bm = BundleManagement::BundleProduct.new
          bm.unpack(declared(params).merge(current_wh: @current_staff.warehouse))
          success_response_with_json('Successfully unpacked bundle product.', HTTP_CODE[:OK])
        rescue BundleManagement::NotFoundError => error
          error!(failure_response_with_json(error.message, HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        rescue BundleManagement::UnacceptableError => error
          error!(failure_response_with_json(error.message, HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to unpacked this variant due to: #{error.message}"
          error!(failure_response_with_json('Unable to unpacked this variant', HTTP_CODE[:FORBIDDEN]),
                 HTTP_CODE[:FORBIDDEN])
        end
      end
    end
  end
end
