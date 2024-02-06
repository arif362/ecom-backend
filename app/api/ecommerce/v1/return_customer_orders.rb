module Ecommerce
  module V1
    class ReturnCustomerOrders < Ecommerce::Base
      helpers Ecommerce::V1::Serializers::ReturnOrderSerializer

      helpers do
        def form_of_return(customer_order)
          if customer_order.home_delivery? || customer_order.express_delivery?
            'from_home'
          else
            'to_partner'
          end
        end
      end

      resource :return_customer_orders do
        # THIS API IS NOT USED AT ALL IN V2
        desc 'Get Line Items'
        params do
          requires :customer_order_id, type: Integer
        end
        get do
          customer_order = @current_user.customer_orders.find_by(id: params[:customer_order_id])
          unless customer_order.present? && (customer_order.status.completed? || customer_order.status.partially_returned?)
            error!(respond_with_json('You are not authorized to see this order or this order is incomplete',
                                     HTTP_CODE[:FORBIDDEN]), HTTP_CODE[:FORBIDDEN])
          end
          return_customer_orders = customer_order.return_customer_orders.where.not(return_status: 'initiated')
          requested_return_order = ReturnCustomerOrder.where(customer_order_id: customer_order.id, return_status: 'initiated')
          reasons = ReturnCustomerOrder.reasons
          { reasons: reasons, return_request_details: return_request_details(customer_order),
            returned_items: show_items(return_customer_orders),
            requested_items: show_items(requested_return_order), }
        rescue StandardError => error
          error!("Can not fetch due to #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Get Return Reasons'
        get '/reasons' do
          reasons = ReturnCustomerOrder.reasons
          bn_reasons = ReturnCustomerOrder::ECOM_BN_REASON
          response = { reasons: reasons, bn_reasons: bn_reasons }
          success_response_with_json('Successfully fetched',
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch Return reasons: #{error.message}"
          error!(failure_response_with_json('Failed to load return reasons',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Get all returned and requested orders'
        get '/lists' do
          return_orders = @current_user.return_customer_orders.order('id DESC')
          return_order_list return_orders
        rescue StandardError => error
          error!("Can not fetch due to #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Get Return Customer Order details.'
        get ':id' do
          return_order = @current_user.aggregate_returns.
                         includes(return_customer_orders: [shopoth_line_item: { variant: :product }],
                                  customer_order: :status).
                         find_by(id: params[:id])
          unless return_order
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.return_customer_order_not_found'),
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          response = Ecommerce::V1::Entities::AggregateReturns.represent(return_order)
          success_response_with_json(I18n.t('Ecom.success.messages.return_order_details_fetch_successful'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch Return Customer Order details due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.return_order_details_fetch_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Request for return order'
        params do
          requires :shopoth_line_item_id, type: Integer
          requires :customer_order_id, type: Integer
          requires :reason, type: Integer
          optional :description, type: String
          optional :images_file
        end
        post do
          customer_order = @current_user.customer_orders.with_no_discount.
                           find(params[:customer_order_id])
          if customer_order.completed_within_seven_days?
            params[:partner_id] = customer_order.partner.present? ? customer_order.partner&.id : nil
            line_item = customer_order.shopoth_line_items.find(params[:shopoth_line_item_id])
            if line_item.returnable?
              aggr_return = customer_order.aggregate_return_create
              return_order = ReturnCustomerOrder.new(params.
                merge(return_type: 'unpacked',
                      qr_code: line_item.qr_codes[0],
                      warehouse: customer_order.warehouse,
                      return_orderable: @current_user,
                      quantity: 1,
                      sub_total: line_item.effective_unit_price,
                      aggregate_return: aggr_return,
                      distributor_id: customer_order.distributor_id,
                      form_of_return: form_of_return(customer_order)))
              return_order.save!
              if return_order.from_home? && aggr_return.address.nil?
                aggr_return.add_address(customer_order.shipping_address)
              end
              aggr_return.update_amount(return_order.form_of_return)
              success_response_with_json(I18n.t('Ecom.success.messages.return_initiate_success'),
                                         HTTP_CODE[:CREATED],
                                         {})
            else
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.non_refundable_error'),
                                                HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                     HTTP_CODE[:OK])
            end
          else
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.non_refundable_error'),
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                   HTTP_CODE[:OK])
          end
        rescue StandardError => error
          Rails.logger.info "Ecom-return request failed - #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.non_refundable_error'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                 HTTP_CODE[:OK])
        end
      end
    end
  end
end
