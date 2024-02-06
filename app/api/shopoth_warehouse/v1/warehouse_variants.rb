module ShopothWarehouse
  module V1
    class WarehouseVariants < ShopothWarehouse::Base

      resource :warehouse_variants do

        # INDEX *************************************************
        desc 'Get all Warehouse Variants'
        get do
          warehouse_variants = WarehouseVariant.all
          warehouse_variants.order(created_at: :desc)
        end
      end
    end
  end
end
