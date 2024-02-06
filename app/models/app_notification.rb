class AppNotification < ApplicationRecord
  belongs_to :notifiable, polymorphic: true

  def self.order_placed_notification(order)
    order_id = order&.backend_id
    # user = order&.customer
    {
      title: 'Order Placed',
      bn_title: 'অর্ডার সম্পন্ন হয়েছে',
      message: "Order no #{order_id} is confirmed for #{order&.name}, phone: #{order.phone}",
      bn_message: "অর্ডার নং #{order_id&.to_bn},#{order&.name} এর জন্য কনফার্ম করা হল, ফোন নং- #{order.phone&.to_bn} ।",
    }
  end

  def self.b2b_order_placed_notification(order)
    order_id = order&.backend_id
    {
      title: 'Order Placed',
      bn_title: 'অর্ডার সম্পন্ন হয়েছে',
      message: "Order no #{order_id} is confirmed.",
      bn_message: "অর্ডার নং #{order_id&.to_bn} এর জন্য কনফার্ম করা হল ।",
    }
  end

  def self.order_delivery_notification(order)
    order_id = order&.backend_id
    # user = order&.customer
    {
      title: 'Order Delivery',
      bn_title: 'অর্ডার ডেলিভারি',
      message: "Order no.#{order_id} of #{order&.name}, phone no: #{order.phone} will be delivered to your outlet for pick and pay delivery",
      bn_message: "অর্ডার নং #{order_id&.to_bn}, #{order.name} এর ফোন নংঃ #{order.phone&.to_bn}, অর্ডারকৃত পণ্য আপনার নির্ধারিত শপথ আউটলেটে পৌঁছে যাবে ।",
    }
  end

  def self.customer_payment_notification(order)
    user = order&.customer
    {
      title: 'Payment from Customer',
      bn_title: 'কাস্টমারের সাথে লেনদেন ।',
      message: "Received #{order&.total_price} taka in cash from #{order&.name}, phone: #{order.phone}",
      bn_message: "#{order.name} এর কাছ থেকে #{order.total_price&.to_s&.to_bn} টাকা নগদে গ্রহণ করা হয়েছে ।",
    }
  end

  def self.order_delivered_to_customer(order)
    user = order&.customer
    {
      title: 'Order Delivered',
      bn_title: 'অর্ডার ডেলিভারি সম্পন্ন হয়েছে।',
      message: "Order no #{order&.backend_id} successfully delivered to #{order&.name}",
      bn_message: "অর্ডার নং #{order&.backend_id&.to_bn},#{order&.name} এর কাছে ডেলিভারি সফল হয়েছে ।",
    }
  end

  def self.return_order_created(return_order)
    {
      title: 'Return Request Created',
      bn_title: 'ফেরত আবেদন তৈরি হয়েছে। ',
      message: "Return request(ID: #{return_order&.id}) successfully created for Order no #{return_order&.customer_order&.backend_id}",
      bn_message: "অর্ডার নং #{return_order&.customer_order&.backend_id&.to_bn} এর জন্য ফেরত আবেদন( আই ডিঃ #{return_order&.id&.to_bn}) তৈরি করতে সফল হয়েছে ।",
    }
  end

  def self.order_purchase_by_partner(order)
    {
      title: 'Order Purchase',
      bn_title: 'অর্ডার ক্রয় ',
      message: "Order Id: #{order&.backend_id} purchase successful",
      bn_message: "অর্ডার নং #{order&.backend_id&.to_bn} ক্রয় সফল হয়েছে ।",
    }
  end

  def self.order_sold_partner(order)
    {
      title: 'Order Sold',
      bn_title: 'অর্ডার বিক্রয়',
      message: "Order Id: #{order&.backend_id} sold successful",
      bn_message: "অর্ডার নং #{order&.backend_id.to_bn} বিক্রয় সফল হয়েছে ।",
    }
  end

  def self.money_transaction_notification(order, amount, form)
    {
      title: 'Money Received',
      bn_title: 'মূল্য পরিশোধিত',
      message: "Received #{amount} taka in #{form} from partner #{order&.partner&.name} for order no #{order&.backend_id}",
      bn_message: "#{order&.partner&.name} পার্টনারের কাছ থেকে #{order&.backend_id&.to_bn} অর্ডার এর জন্য #{amount&.to_s&.to_bn} টাকা গৃহীত হয়েছে। ",
    }
  end

  def self.wallet_transaction_notification(order, amount)
    {
      title: 'Money Received',
      message: "Received #{amount} taka in wallet for order no #{order&.backend_id}",
    }
  end

  def self.payment_exceeded(order)
    {
      title: 'Payment Extended',
      bn_title: 'মূল্য পরিশোধ করার সময় বাড়ানো হয়েছে ।',
      message: "Time has extended for Order Id: #{order&.backend_id}",
      bn_message: "#{order&.backend_id.to_bn} অর্ডার এর জন্য মূল্য পরিশোধ করার সময় বাড়ানো হয়েছে।",
    }
  end

  def self.new_partner_note(order)
    {
      title: 'Partner Switched',
      bn_title: 'পার্টনার বদল',
      message: "Order no. #{order&.backend_id} will be delivered to your outlet",
      bn_message: "অর্ডার নং #{order&.backend_id&.to_bn} আপনার আউটলেটে পৌঁছে যাবে ।",
    }
  end

  def self.previous_partner_note(order)
    {
      title: 'Shipping Changed',
      bn_title: 'শিপিং পরিবর্তন',
      message: "Order no. #{order&.backend_id} has been changed it's shipping from your outlet",
      bn_message: "আপনার আউটলেট থেকে অর্ডার #{order&.backend_id&.to_bn} এর শিপিং পরিবর্তন করা হয়েছে ।",
    }
  end

  def self.sr_note(order)
    {
      title: 'Shipping Changed',
      bn_title: 'শিপিং পরিবর্তন',
      message: "Order no. #{order&.backend_id} has been changed it's shipping",
      bn_message: "অর্ডার #{order&.backend_id&.to_bn} এর শিপিং পরিবর্তন করা হয়েছে ।",
    }
  end

  def self.rider_note(order)
    {
      title: 'Shipping Changed',
      bn_title: 'শিপিং পরিবর্তন',
      message: "Order no. #{order&.backend_id} has been changed it's shipping",
      bn_message: "অর্ডার #{order&.backend_id&.to_bn} এর শিপিং পরিবর্তন করা হয়েছে।",
    }
  end
end