module ShopothWarehouse
  module V1
    class Inventories < ShopothWarehouse::Base
      resource :inventories do
        desc 'Return list of products.'
        params do
          use :pagination, per_page: 50
        end
        get '/products' do
          warehouse = @current_staff.warehouse
          if check_wh_warehouse
            if params[:warehouse_id].present?
              dwh = Warehouse.find_by(id: params[:warehouse_id])
              variants = dwh.variants.includes(:warehouse_variants)
              variants = Variant.filter_by(variants, params[:company], params[:category], params[:sub_category], params[:sku], params[:product_title])
              # TODO: Need to Optimize Query
              ShopothWarehouse::V1::Entities::InventoryVariantsDistribution.represent(
                paginate(Kaminari.paginate_array(variants)), warehouse_id: params[:warehouse_id]
              )
            else
              variants = Variant.filter_by(nil, params[:company], params[:category], params[:sub_category], params[:sku], params[:product_title])
              # TODO: Need to Optimize Query
              ShopothWarehouse::V1::Entities::InventoryVariantsCentral.represent(
                paginate(Kaminari.paginate_array(variants)), warehouse_id: warehouse.id
              )
            end
          elsif check_dh_warehouse
            variants = Variant.filter_by(warehouse.variants, params[:company], params[:category], params[:sub_category], params[:sku], params[:product_title])
            # TODO: Need to Optimize Query
            ShopothWarehouse::V1::Entities::InventoryVariantsDistribution.represent(
              paginate(Kaminari.paginate_array(variants)), warehouse_id: warehouse.id
            )
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to return products due to: #{error.message}"
          error!(success_response_with_json('Unable to return products.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        desc 'Get distribution warehouse list.'
        get '/warehouses' do
          warehouses = Warehouse.select(:id, :name).distribution_house
          { warehouses: warehouses, status: HTTP_CODE[:OK] }
        end

        desc 'Export products.'
        get '/export' do
          warehouse = @current_staff.warehouse
          if check_wh_warehouse
            if params[:warehouse_id].present?
              dwh = Warehouse.find_by(id: params[:warehouse_id])
              variants = dwh.variants.includes(:warehouse_variants)
              variants = Variant.filter_by(variants, params[:company], params[:category], params[:sub_category], params[:sku], params[:product_title])
              ShopothWarehouse::V1::Entities::InventoryVariantsDistribution.represent(variants, warehouse_id: params[:warehouse_id])
            else
              variants = Variant.filter_by(nil, params[:company], params[:category], params[:sub_category], params[:sku], params[:product_title])
              ShopothWarehouse::V1::Entities::InventoryVariantsCentral.represent(variants, warehouse_id: warehouse.id)
            end
          elsif check_dh_warehouse
            variants = Variant.filter_by(warehouse.variants, params[:company], params[:category], params[:sub_category], params[:sku], params[:product_title])
            ShopothWarehouse::V1::Entities::InventoryVariantsDistribution.represent(variants, warehouse_id: warehouse.id)
          end
        rescue => error
          Rails.logger.error "\n#{__FILE__}\nUnable to return products due to: #{error.message}"
          error!("Unable to return product due to #{error.message}")
        end
      end
    end
  end
end
