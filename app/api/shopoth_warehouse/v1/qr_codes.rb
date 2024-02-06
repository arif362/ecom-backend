module ShopothWarehouse
  module V1
    class QrCodes < ShopothWarehouse::Base
      resource :qr_codes do
        params do
          requires :line_item_id,
                   type: Integer,
                   allow_blank: false
          #validate_line_item: false
        end

        get 'generate' do
          line_item_id = params[:line_item_id]
          line_item = LineItem.find(line_item_id)
          line_item_context = QrCode::GenerateQrCode.call(line_item: line_item)
          if line_item_context.success?
            success_response_with_json('', HTTP_CODE[:OK], line_item_context.updated_line_item)
          else
            respond_with_json(line_item_context.error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        rescue StandardError => ex
          error! respond_with_json("Unable to fetch order details due to #{ex.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
