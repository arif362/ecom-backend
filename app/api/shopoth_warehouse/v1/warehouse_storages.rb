module ShopothWarehouse
  module V1
    class WarehouseStorages < ShopothWarehouse::Base

      resource :warehouse_storages do

        # INDEX *************************************************
        desc 'Get all warehouse_storages'
        get do
          warehouse_storages = WarehouseStorage.where(is_deleted: false)
          paginate(warehouse_storages.order(created_at: :desc))
        end

        # CREATE ************************************************
        desc 'Create a new warehouse_storage'
        params do
          requires :warehouse_id, type: Integer
          requires :name, type: String
          requires :bn_name, type: String
          requires :area, type: String
          requires :location, type: String
        end

        post do
          warehouse_storage = WarehouseStorage.new(params)
          warehouse_storage if warehouse_storage.save!
        rescue StandardError
          error! respond_with_json('Unable to create Warehouse_Storage.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # UPDATE ************************************************
        desc 'Update a warehouse_storage'
        params do
          requires :id, type: String, desc: 'Identification'
        end

        route_param :id do
          put do
            warehouse_storage = WarehouseStorage.find(params[:id])
            warehouse_storage if warehouse_storage.update!(params)
          rescue StandardError
            error! respond_with_json('Unable to update Warehouse_Storage.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        # DELETE ************************************************
        desc 'Delete a warehouse_storage'
        params do
          requires :id, type: String, desc: 'Identification'
        end

        route_param :id do
          delete do
            warehouse_storage = WarehouseStorage.find(params[:id])
            'Successfully deleted' if warehouse_storage.update!(is_deleted: true)
          rescue StandardError
            error! respond_with_json('Unable to delete Warehouse_Storage.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
