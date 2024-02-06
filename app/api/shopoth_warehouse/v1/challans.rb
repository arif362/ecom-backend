module ShopothWarehouse
  module V1
    class Challans < ShopothWarehouse::Base
      resource :challans do
        desc 'Get all Challans.'
        params do
          use :pagination, per_page: 50
          optional :status, type: String, values: Challan.statuses.keys
          optional :distributor_id, type: Integer
        end
        get do
          challans = @current_staff.warehouse.challans.order(id: :desc)
          challans = challans.where(distributor_id: params[:distributor_id]) if params[:distributor_id].present?
          challans = challans.where(status: params[:status]) if params[:status].present?
          # TODO: Need to Optimize Query
          challans = paginate(Kaminari.paginate_array(challans))
          challans = ShopothWarehouse::V1::Entities::Challans.represent(challans, list: true)

          success_response_with_json('Challans fetched successfully', HTTP_CODE[:OK], challans)

        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch Challans due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch Challans.', HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Fetch customer orders for chalan creation.'
        params do
          use :pagination, per_page: 50
          optional :skip_pagination, type: Boolean
          optional :start_date_time, type: DateTime
          optional :end_date_time, type: DateTime
          requires :distributor_id, type: Integer
        end
        get '/orders' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.utc.beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.utc.end_of_month

          date_range = start_date_time..end_date_time
          status_id = OrderStatus.getOrderStatus(OrderStatus.order_types[:ready_to_ship_from_fc]).id
          distributor = @current_warehouse.distributors.find_by(id: params[:distributor_id])
          unless distributor
            error!(failure_response_with_json('Distributor not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          customer_orders = distributor.customer_orders.where(created_at: date_range, order_status_id: status_id).includes(:status, :warehouse)
          order_ids = customer_orders.ids - customer_orders.joins(:challan_line_item).ids
          # TODO: Need to Optimize Query
          customer_orders = if params[:skip_pagination]
                              customer_orders.where(id: order_ids)
                            else
                              paginate(Kaminari.paginate_array(customer_orders.where(id: order_ids)))
                            end

          response = ShopothWarehouse::V1::Entities::CustomerOrders.represent(customer_orders)
          success_response_with_json('Successfully fetched customer orders.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.info "Unable to fetch customer orders due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch customer orders.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Get a specific Challan.'
        route_param :id do
          get do
            challan = Challan.find(params[:id])
            challan = ShopothWarehouse::V1::Entities::Challans.represent(challan)
            success_response_with_json('Challan fetched successfully', HTTP_CODE[:OK], challan)
          rescue ::ActiveRecord::RecordNotFound
            error!(failure_response_with_json('Challan not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to fetch Challan details due to: #{error.message}"
            error!(failure_response_with_json('Unable to fetch Challan details.', HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
        end

        desc 'Create a new Challan.'
        params do
          requires :distributor_id, type: Integer
          requires :order_ids, type: Array do
            requires type: Integer
          end
        end
        post do
          create_params = params.merge(challan_line_items_attributes: params[:order_ids].map{ |oi| {customer_order_id: oi} })
                                .except(:order_ids)

          challan = Challan.new(create_params)
          challan.created_by_id = @current_staff&.id
          challan.warehouse_id = @current_staff&.warehouse.id
          challan.save!
          challan = ShopothWarehouse::V1::Entities::Challans.represent(challan)
          success_response_with_json('Challan created successfully', HTTP_CODE[:OK], challan)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create Challan due to: #{error.message}"
          error!(failure_response_with_json("Unable to create Challan: #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Dispatch challan.'
        route_param :id do
          put :dispatch do
            challan = Challan.find(params[:id])
            challan.dispatch! @current_staff
            challan = ShopothWarehouse::V1::Entities::Challans.represent(challan)
            success_response_with_json('Challan dispatch successfully', HTTP_CODE[:OK], challan)
          rescue ::ActiveRecord::RecordNotFound
            error!(failure_response_with_json('Challan not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to dispatch Challan due to: #{error.full_message}"
            error!(failure_response_with_json("Unable to dispatch Challan due to: #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:OK])
          end
        end

        desc 'Remove order from challan.'
        route_param :id do
          params do
            requires :order_id
          end
          delete :remove_order do
            challan = Challan.find(params[:id])
            cli = challan.challan_line_items.find_by(customer_order_id: params[:order_id])
            unless cli
              error!(failure_response_with_json('Order not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end
            cli.destroy!
            success_response_with_json('Remove order from challan successfully.', HTTP_CODE[:OK])
          rescue ::ActiveRecord::RecordNotFound
            error!(failure_response_with_json('Challan not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to remove order from challan due to: #{error.full_message}"
            error!(failure_response_with_json('Unable to remove order from challan.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:OK])
          end
        end

        desc 'Delete a specific Challan.'
        route_param :id do
          delete ':id' do
            challan = Challan.find(params[:id])
            challan.update!(is_deleted: true)
          rescue ::ActiveRecord::RecordNotFound
            error!(failure_response_with_json('Challan not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to delete Challan due to: #{error.message}"
            error!(failure_response_with_json('Unable to delete', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
