module ShopothWarehouse
  module V1
    class StorageVariants < ShopothWarehouse::Base

      resource :storage_variants do

        # INDEX *************************************************
        desc 'Get all Storage Variants'
        get do
          StorageVariant.all
        end

        # CREATE ************************************************
        desc 'Create a new Storage Variant'
        params do
          requires :storage_variant, type: Hash do
            requires :warehouse_storage_id, type: Integer
            requires :variant_id, type: Integer
            requires :quantity, type: Integer
          end
        end

        post do
          storage_variant = StorageVariant.new(params[:storage_variant])
          storage_variant if storage_variant.save!
        rescue StandardError => error
          error!("Unable to create Storage Variant due to #{error.message}")
        end

        # UPDATE ************************************************
        desc 'Update a Storage Variant'
        params do
          requires :id, type: String, desc: 'Identification'
        end

        route_param :id do
          put do
            storage_variant = StorageVariant.find(params[:id])
            storage_variant if storage_variant.update!(params[:storage_variant])
          rescue StandardError => error
            error!("Unable to update Storage Variant due to #{error.message}")
          end
        end

        # DELETE ************************************************
        desc 'Delete a Storage Variant'
        params do
          requires :id, type: String, desc: 'Identification'
        end

        route_param :id do
          delete do
            storage_variant = StorageVariant.find(params[:id])
            'Successfully deleted.' if storage_variant.destroy!
          rescue StandardError => error
            error!("Unable to delete Storage Variant due to #{error.message}")
          end
        end
      end
    end
  end
end

