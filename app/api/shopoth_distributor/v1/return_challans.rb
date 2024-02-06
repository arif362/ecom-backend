module ShopothDistributor
  module V1
    class ReturnChallans < ShopothDistributor::Base
      resource :return_challans do
        desc 'Get all ReturnChallans.'
        params do
          use :pagination, per_page: 50
          optional :status, type: String, values: ReturnChallan.statuses.keys
        end
        get do
          return_challans = @current_distributor.return_challans.order(id: :desc)
          return_challans = return_challans.where(status: params[:status]) if params[:status].present?
          return_challans = paginate(Kaminari.paginate_array(return_challans))
          return_challans = ShopothDistributor::V1::Entities::ReturnChallans.represent(return_challans, list: true)

          success_response_with_json('ReturnChallans fetched successfully', HTTP_CODE[:OK], return_challans)

        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch ReturnChallans due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch ReturnChallans.', HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Get all Available Order for ReturnChallan.'
        params do
          use :pagination, per_page: 50
          requires :order_type, type: String, values: %w[CustomerOrder ReturnCustomerOrder]
        end
        get :available_orders do
          filters_with = {}
          filters_with_out = {}
          if params[:order_type] == 'ReturnCustomerOrder'
            filters_with[:return_status] = :delivered_to_dh
            filters_with_out[:id] = ReturnChallanLineItem.select(:orderable_id).where(orderable_type: 'ReturnCustomerOrder').map(&:orderable_id)
          else
            filters_with[:order_status_id] = OrderStatus.getOrderStatus(OrderStatus.order_types[:cancelled_at_dh])&.id
            filters_with_out[:id] = ReturnChallanLineItem.select(:orderable_id).where(orderable_type: 'CustomerOrder').map(&:orderable_id)
          end
          orders = eval("@current_distributor.#{params[:order_type].tableize}.where(filters_with).where.not(filters_with_out).order(id: :desc)")
          orders = paginate(Kaminari.paginate_array(orders))
          orders = eval("ShopothDistributor::V1::Entities::#{params[:order_type]}.represent(orders, list: true)")

          success_response_with_json("#{params[:order_type]} fetched successfully", HTTP_CODE[:OK], orders)

        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch #{params[:order_type]} due to: #{error.message}"
          error!(failure_response_with_json("Unable to fetch #{params[:order_type]}.", HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end


        desc 'Get a specific ReturnChallan.'
        route_param :id do
          get do
            return_challan = ReturnChallan.find(params[:id])
            return_challan = ShopothDistributor::V1::Entities::ReturnChallans.represent(return_challan)
            success_response_with_json('ReturnChallan fetched successfully', HTTP_CODE[:OK], return_challan)
          rescue ::ActiveRecord::RecordNotFound
            error!(failure_response_with_json('ReturnChallan not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to fetch ReturnChallan details due to: #{error.message}"
            error!(failure_response_with_json('Unable to fetch ReturnChallan details.', HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
        end


        desc 'Create a new ReturnChallan.'
        params do
          optional :cancelled_order_ids, type: Array
          optional :returned_order_ids, type: Array
        end
        post do
          order_id_and_types = params[:cancelled_order_ids]&.map{ |coi| {orderable_id: coi.to_i, orderable_type: 'CustomerOrder'} } || []
          params[:returned_order_ids]&.each{ |roi| order_id_and_types << {orderable_id: roi.to_i, orderable_type: 'ReturnCustomerOrder'} }

          create_params = params.merge(return_challan_line_items_attributes: order_id_and_types)
                                .except(:cancelled_order_ids, :returned_order_ids)

          return_challan = ReturnChallan.new(create_params)
          return_challan.created_by_id = @current_staff&.id
          return_challan.distributor_id = @current_distributor&.id
          return_challan.warehouse_id = @current_distributor&.warehouse&.id
          return_challan.save!
          return_challan = ShopothDistributor::V1::Entities::ReturnChallans.represent(return_challan)
          success_response_with_json('ReturnChallan created successfully', HTTP_CODE[:OK], return_challan)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create ReturnChallan due to: #{error.message}"
          error!(failure_response_with_json("Unable to create ReturnChallan: #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end


        desc 'Dispatch return_challan.'
        route_param :id do
          put :dispatch do
            return_challan = ReturnChallan.find(params[:id])
            return_challan.dispatch! @current_staff
            return_challan = ShopothDistributor::V1::Entities::ReturnChallans.represent(return_challan)
            success_response_with_json('ReturnChallan dispatch successfully', HTTP_CODE[:OK], return_challan)
          rescue ::ActiveRecord::RecordNotFound
            error!(failure_response_with_json('ReturnChallan not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to dispatch ReturnChallan due to: #{error.full_message}"
            error!(failure_response_with_json('Unable to dispatch ReturnChallan.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:OK])
          end
        end


        desc 'Remove order from return_challan.'
        route_param :id do
          params do
            requires :orderable_id, type: Integer
            requires :orderable_type, type: String
          end
          delete :remove_order do
            return_challan = ReturnChallan.find(params[:id])
            rli = return_challan.return_challan_line_items.find_by(orderable_id: params[:orderable_id], orderable_type: params[:orderable_type])
            unless rli
              error!(failure_response_with_json('Order not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end
            rli.destroy!
            success_response_with_json('Remove order from return_challan successfully.', HTTP_CODE[:OK])
          rescue ActiveRecord::RecordNotFound => error
            error!(failure_response_with_json('ReturnChallan not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to remove order from return_challan due to: #{error.full_message}"
            error!(failure_response_with_json('Unable to remove order from return_challan.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:OK])
          end
        end


        desc 'Delete a specific ReturnChallan.'
        route_param :id do
          delete ':id' do
            return_challan = ReturnChallan.find(params[:id])
            return_challan.update!(is_deleted: true)
          rescue ::ActiveRecord::RecordNotFound
            error!(failure_response_with_json('ReturnChallan not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to delete ReturnChallan due to: #{error.message}"
            error!(failure_response_with_json('Unable to delete', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
