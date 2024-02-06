module ShopothWarehouse
  module V1
    class PartnerShops < ShopothWarehouse::Base

      resource :partner_shops do

        # INDEX *************************************************
        desc 'Get all Partner Shops'
        get do
          partner_shops = PartnerShop.all
          paginate(partner_shops.order(created_at: :desc))
        end

        # CREATE ************************************************
        desc 'Create a new Partner Shop'
        params do
          requires :sales_representative_id, type: Integer
          requires :day, type: String
        end

        post do
          partner_shop = PartnerShop.new(params)
          partner_shop if partner_shop.save!
        rescue StandardError
          error! respond_with_json('Unable to create Partner_Shop.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # UPDATE ************************************************
        desc 'Update a Partner Shop'
        params do
          requires :id, type: String, desc: 'Identification'
        end

        route_param :id do
          put do
            partner_shop = PartnerShop.find(params[:id])
            partner_shop if partner_shop.update!(params)
          rescue StandardError
            error! respond_with_json('Unable to update Partner_Shop.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end

