namespace :negative_amount_update do
  desc 'script for negative value update for customer order amount'
  task setup: :environment do |t, args|
    order_ids = [195, 209, 349, 465, 618, 625, 633, 758, 930, 936, 940, 1029, 1127, 1132, 1153, 1161, 1172, 1177, 1190, 1194, 1211, 1212, 1220, 1222, 1223, 1228, 1232, 1235, 1236, 1254, 1376, 1380, 1385, 1397, 1401, 1407, 1415, 1418, 1421, 1439, 1485, 1495, 1506, 1624, 1880, 1886, 1895, 1898, 1907, 1908, 1911, 1915, 1917, 1919, 1922, 1926, 1930, 1934, 1942, 1946, 1947, 1958, 2062, 2401, 2412, 2417, 2462]
    order_ids.each do |i|
      commission = 0.0
      order = CustomerOrder.find(i)
      order&.shopoth_line_items.each do |line_item|
        line_item.update(retailer_price: line_item.variant.price_retailer.to_f)
        commission += (line_item.variant.price_consumer.to_f - line_item.variant.price_retailer.to_f) * line_item.quantity
      end
      order.update!(partner_commission: commission)
    end
  end
end