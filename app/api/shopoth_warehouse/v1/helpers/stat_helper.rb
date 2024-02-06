module ShopothWarehouse::V1::Helpers
  module StatHelper
    extend Grape::API::Helpers

    def filter_type(grouped_order)
      result = {}
      grouped_order.each do |type, orders|
        orders.each do |o|
          result[o.created_at.strftime('%d-%m-%Y')] ||= {}
          result[o.created_at.strftime('%d-%m-%Y')][type] ||= 0
          result[o.created_at.strftime('%d-%m-%Y')][type] += 1
        end
      end
      result
    end

    def group_by_date(all_orders)
      all_orders.group_by { |cus_order| cus_order.created_at.strftime('%d-%m-%Y') }
    end

    def get_sku_details(variants)
      data = []
      variants.each do |key, val|
        v = Variant.find_by(sku: key)
        product = Product.unscoped.find_by(id: v.product_id, is_deleted: false)
        next unless v.present?

        data.push({
                    title: product&.title || '',
                    sku: v.sku,
                    company: product&.company,
                    units: val,
                    categories: fetch_categories(product&.categories&.where(parent_id: nil)),
                    sub_categories: fetch_categories(product&.categories&.where&.not(parent_id: nil)),
                  })
      end
      data
    end

    def fetch_categories(categories)
      return [] unless categories.present?

      cats = []
      categories.each do |cat|
        cats.push(cat.title)
      end
      cats
    end

    def max_value_by_order_type(data)
      induced = data.max_by { |h| h[:induced] }[:induced]
      organic = data.max_by { |h| h[:organic] }[:organic]
      induced > organic ? induced : organic
    end

    def max_value_by_deliver_type(data)
      values = []
      values[0] = data.max_by { |h| h[:home] }[:home]
      values[1] = data.max_by { |h| h[:express] }[:express]
      values[2] = data.max_by { |h| h[:pick_up] }[:pick_up]
      values.max
    end

    def stat_based_on_order_type(all_orders, dates)
      grouped_order = all_orders.group_by(&:order_type)
      result = filter_type(grouped_order)
      response_json = {
        data: [],
        total_order_in_7_days: all_orders.length,
        x_axis: {},
        y_axis: {},
      }
      dates.each do |date|
        organic = result[date].present? ? result[date]['organic'] : 0
        induced = result[date].present? ? result[date]['induced'] : 0
        response_json[:data].
          push({ date: date,
                 organic: organic || 0,
                 induced: induced || 0, })
      end
      response_json[:max_value] = response_json[:data].empty? ? 0 : max_value_by_order_type(response_json[:data])
      response_json[:y_axis] = { y1: 'organic', y2: 'induced' }
      response_json[:x_axis] = { x1: 'date' }
      response_json
    end

    def stat_based_on_shipping_type(all_orders, dates)
      grouped_order = all_orders.group_by(&:shipping_type)
      result = filter_type(grouped_order)
      response_json = { data: [], total_order_in_7_days: all_orders.length, x_axis: {}, y_axis: {} }
      dates.each do |date|
        home_delivery = result[date].present? ? result[date]['home_delivery'] : 0
        express_delivery = result[date].present? ? result[date]['express_delivery'] : 0
        pick_up_point = result[date].present? ? result[date]['pick_up_point'] : 0
        response_json[:data].
          push({ date: date,
                 home: home_delivery || 0,
                 express: express_delivery || 0,
                 pick_up: pick_up_point || 0, })
      end
      response_json[:max_value] = response_json[:data].empty? ? 0 : max_value_by_deliver_type(response_json[:data])
      response_json[:y_axis] = { y1: 'home', y2: 'express', y3: 'pick_up' }
      response_json[:x_axis] = { x1: 'date' }
      response_json
    end

    def value_discount(all_orders, dates)
      total_orders = group_by_date(all_orders)
      response_json = { data: [], total_order_in_7_days: all_orders.length }
      dates.each do |date|
        response_json[:data].
          push({ date: date,
                 price: total_orders[date]&.inject(0) { |sum, o| sum + (o[:total_price] || 0.0) }&.truncate(2) || 0.00, })
      end
      response_json[:y_axis] = { y1: 'price' }
      response_json[:x_axis] = { x1: 'date' }
      response_json[:max_value] = response_json[:data].empty? ? 0 : response_json[:data].max_by { |h| h[:price] }[:price]
      response_json
    end

    def cart_mrp(all_orders, dates)
      total_orders = group_by_date(all_orders)
      response_json = { data: [], total_order_in_7_days: all_orders.length }
      dates.each do |date|
        response_json[:data].
          push({ date: date,
                 price: total_orders[date]&.inject(0) do |sum, o|
                   sum + ((o[:cart_total_price] || 0.0) + (o[:shipping_charge] || 0.0))
                 end&.truncate(2) || 0.00, })
      end
      response_json[:y_axis] = { y1: 'price' }
      response_json[:x_axis] = { x1: 'date' }
      response_json[:max_value] =  response_json[:data].empty? ? 0 : response_json[:data].max_by { |h| h[:price] }[:price]
      response_json
    end

    def top_10_sku(all_orders)
      completed = OrderStatus.find_by(order_type: 'completed').id
      all_orders = all_orders.where(order_status_id: completed).includes(:shopoth_line_items)
      response_json = { data: {}, format: 'table' }
      all_orders.each do |order|
        order.shopoth_line_items.each do |l|
          if l.variant.present?
            response_json[:data][l.variant.sku] ||= 0
            response_json[:data][l.variant.sku] += l.quantity
          end
        end
      end
      response_json[:data] = response_json[:data].sort_by { |_k, v| v }.reverse.first(10).to_h
      response_json[:data] = get_sku_details(response_json[:data])
      response_json
    end

    def avg_basket_value(all_orders, dates)
      total_orders = group_by_date(all_orders)
      response_json = { data: [], total_order_in_7_days: all_orders.length }
      dates.each do |date|
        total_price = if total_orders[date].present?
                        total_orders[date].inject(0) do |sum, o|
                          sum + ((o[:cart_total_price] || 0.0) + (o[:shipping_charge] || 0.0))
                        end
                      else
                        0.0
                      end
        count = total_orders[date].present? ? total_orders[date].size : 1
        response_json[:data].
          push({ date: date,
                 price: (total_price / count).truncate(2), })
      end
      response_json[:y_axis] = { y1: 'price' }
      response_json[:x_axis] = { x1: 'date' }
      response_json[:max_value] =  response_json[:data].empty? ? 0 : response_json[:data].max_by { |h| h[:price] }[:price]
      response_json
    end
  end
end
