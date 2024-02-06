module Ecommerce::V1::Serializers
  module CurrentUserDetailsSerializer
    extend Grape::API::Helpers

    def get_address(user)
      Jbuilder.new.key do |json|
        json.first_name user.first_name
        json.last_name user.last_name
        json.email user.email
        json.phone user.phone
        json.address_information do
          json.address_line user&.address&.address_line
          json.area user&.address&.area&.name
          json.thana user&.address&.thana&.name
          json.district user&.address&.district&.name
          json.post_code user&.address&.zip_code
        end
      end
    end

    def get_pickup_details(del_preferences)
      Jbuilder.new.key do |json|
        json.array! del_preferences do |preference|
          json.delivery_preference_id preference.id
          json.pay_type preference.pay_type
          json.shipping_type preference.shipping_type
          json.default preference.default
          json.partner_details do
            json.partner_name preference&.partner&.name
            json.partner_phone preference&.partner&.phone
            json.partner_schedule preference&.partner&.schedule.humanize
            json.slug preference.partner&.slug
            json.position get_location(preference&.partner&.latitude, preference&.partner&.longitude)
            json.partner_address do
              json.area preference&.partner&.address&.area&.name
              json.thana preference&.partner&.address&.thana&.name
              json.district preference&.partner&.address&.district&.name
              json.address_line preference&.partner&.address&.address_line
              json.post_code preference&.partner&.address&.zip_code
            end
          end
        end
      end
    end

    def get_home_delivery_details(del_preferences)
      Jbuilder.new.key do |json|
        json.array! del_preferences do |preference|
          json.delivery_preference_id preference.id
          json.user_name "#{preference&.user&.first_name} #{preference&.user&.last_name}"
          json.pay_type preference.pay_type
          json.shipping_type preference.shipping_type
          json.default preference.default
          json.home_delivery_address_details do
            json.phone preference&.address&.phone
            json.area preference&.address&.area&.name
            json.thana preference&.address&.thana&.name
            json.district preference&.address&.district&.name
            json.address_line preference&.address&.address_line
            json.post_code preference&.address&.zip_code
          end
        end
      end
    end

    def get_location(latitude, longitude)
      "https://www.google.com/maps/search/?api=1&query=#{latitude},#{longitude}"
    end
  end
end
