module ShopothWarehouse
  module V1
    class ProductTypes < ShopothWarehouse::Base
      resource :product_types do

        # CREATE ************************************************
        desc 'Create a new product type'
        params do
          requires :product_type, type: Hash do
            requires :title, type: String
            requires :bn_title, type: String
            requires :slug, type: String
          end
        end

        post do
          product_type = ProductType.new(params[:product_type])
          product_type.as_json(except: [:created_at, :updated_at]) if product_type.save!
        rescue => ex
          error!("Unable to create product type due to #{ex.message}")
        end

        # Update **********

        desc 'Update a specific product type'
        route_param :id do
          put do
            product_type = ProductType.find(params[:id])
            product_type.update(params[:product_type])
            product_type.as_json(except: [:created_at, :updated_at])
          rescue => ex
            error!("Unable to update product type due to #{ex.message}")
          end
        end

        # List ***********
        get do
          product_types = ProductType.all
          # TODO: Need to Optimize Query
          present Kaminari.paginate_array(product_types), with: ShopothWarehouse::V1::Entities::ProductTypes
        end

        # Single Product Type **********
        desc 'Single product type'
        get ':id' do
          product_type = ProductType.find(params[:id])
          product_type.as_json(except: [:created_at, :updated_at])
        rescue => ex
          error!("Unable to find product type due to #{ex.message}")
        end

        # Destroy Product Type **********
        route_param :id do
          delete do
            product_type = ProductType.find(params[:id])
            respond_with_json 'Successfully delete product type!', HTTP_CODE[:OK] if product_type.destroy!
          rescue => ex
            error!("Cannot delete product type due to #{ex.message}")
          end
        end
      end
    end
  end
end
