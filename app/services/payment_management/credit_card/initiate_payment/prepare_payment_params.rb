module PaymentManagement
  module CreditCard
    class InitiatePayment
      class PreparePaymentParams
        include Interactor

        delegate :order, :payment, :params, :customer, :sub_domain, to: :context
        delegate :shipping_address, :shipping_type, :partner, :tenure, to: :order

        CUS_COUNTRY = 'Bangladesh'.freeze
        PRODUCT_CATEGORY = 'General'.freeze
        FALLBACK_ZIPCODE = 1
        FALLBACK_EMAIL = 'development@shopoth.com'.freeze

        def call
          context.params = {}
          params.merge!(
            authentication_info,
            payment_info,
            emi_info,
            customer_info,
            shipment_info,
            product_info,
            additional_info,
            callback_urls,
          )
        end

        private

        def authentication_info
          # TODO: Rails.application.credentials.dig(:ssl_commerz, :store_id) not working
          {
            store_id: ENV['SSL_COMMERZ_STORE_ID'],
            store_passwd: ENV['SSL_COMMERZ_STORE_PASSWORD'],
          }
        end

        def payment_info
          {
            total_amount: payment.currency_amount,
            currency: payment.currency_type,
            tran_id: order.id,
          }
        end

        def emi_info
          # TODO: Here customer will get emi_max_inst_option 3, 6, 9, 12, etc instalment.
          return { emi_option: 0 } unless order.emi_payment?

          {
            emi_option: 1,
            # emi_max_inst_option: 12,
            emi_selected_inst: tenure,
            emi_allow_only: 1,
          }
        end

        def customer_info
          # TODO: map matching data from DB
          {
            cus_name: customer&.full_name,
            cus_email: customer&.email || FALLBACK_EMAIL,
            cus_add1: shipping_address&.address_line || partner&.address&.address_line || '',
            cus_add2: shipping_address&.area&.name || partner&.address&.area&.name || '',
            cus_city: shipping_address&.thana&.name || partner&.address&.thana&.name || '',
            cus_state: shipping_address&.district&.name || partner&.address&.district&.name || '',
            cus_postcode: shipping_address&.zip_code || partner&.address&.zip_code || FALLBACK_ZIPCODE,
            cus_country: CUS_COUNTRY,
            cus_phone: customer&.phone,
            cus_fax: '',
          }
        end

        def shipment_info
          # TODO: map matching data from DB
          {
            shipping_method: order.shipping_type,
            num_of_items: order.item_count,
            ship_name: shipping_address&.title || partner&.address&.title || '',
            ship_add1: shipping_address&.address_line || partner&.address&.address_line || '',
            ship_add2: shipping_address&.area&.name || partner&.address&.area&.name || '',
            ship_city: shipping_address&.thana&.name || partner&.address&.thana&.name || '',
            ship_state: shipping_address&.district&.name || partner&.address&.district&.name || '',
            ship_postcode: shipping_address&.zip_code || partner&.address&.zip_code || FALLBACK_ZIPCODE,
            ship_phone: order&.phone,
            ship_country: CUS_COUNTRY,
          }
        end

        def product_info
          # TODO: map matching data from DB
          {
            product_name: order.shopoth_line_items.map { |l| l.variant&.product&.title&.first(15) || '' }.join(','),
            product_category: PRODUCT_CATEGORY,
            product_profile: PRODUCT_CATEGORY,
          }
        end

        def additional_info
          {
            value_a: '',
            value_b: '',
            value_c: '',
            value_d: '',
          }
        end

        def callback_urls
          {
            ipn_url: ipn_url,
            success_url: success_url,
            fail_url: fail_url,
            cancel_url: cancel_url,
          }
        end

        def ipn_url
          return 'https://api.shopoth.com/shop/api/v1/payment/credit_card/ipn' if Rails.env.production?
          return 'http://api.shopoth.net/shop/api/v1/payment/credit_card/ipn' if Rails.env.pre_prod?
          return 'http://api.shopoth.shop/shop/api/v1/payment/credit_card/ipn' if Rails.env.staging?
          return 'http://api-v2.shopoth.net/shop/api/v1/payment/credit_card/ipn' if Rails.env.pre_prod_v2?
          return 'http://api-v2.shopoth.shop/shop/api/v1/payment/credit_card/ipn' if Rails.env.staging_v2?

          'http://localhost:3000/shop/api/v1/payment/credit_card/ipn'
        end

        def success_url
          if Rails.env.production?
            return "https://#{domain_name}.com/order-success?shipping_type=#{order.shipping_type}&id=#{order.id}"
          end
          if Rails.env.pre_prod?
            return "http://#{domain_name}.net/order-success?shipping_type=#{order.shipping_type}&id=#{order.id}"
          end
          if Rails.env.staging?
            return "http://#{domain_name}.shop/order-success?shipping_type=#{order.shipping_type}&id=#{order.id}"
          end
          if Rails.env.staging_v2?
            return "http://#{domain_name}.shop/order-success?shipping_type=#{order.shipping_type}&id=#{order.id}"
          end
          if Rails.env.pre_prod_v2?
            return "http://#{domain_name}.net/order-success?shipping_type=#{order.shipping_type}&id=#{order.id}"
          end

          "http://localhost:3000/order-success?shipping_type=#{order.shipping_type}&id=#{order.id}"
        end

        def fail_url
          return "https://#{domain_name}.com/order-failure" if Rails.env.production?
          return "http://#{domain_name}.net/order-failure" if Rails.env.pre_prod?
          return "http://#{domain_name}.shop/order-failure" if Rails.env.staging?
          return "http://#{domain_name}.shop/order-failure" if Rails.env.staging_v2?
          return "http://#{domain_name}.net/order-failure" if Rails.env.pre_prod_v2?

          'http://localhost:3000/order-failure'
        end

        def cancel_url
          return "https://#{domain_name}.com/order-cancel" if Rails.env.production?
          return "http://#{domain_name}.net/order-cancel" if Rails.env.pre_prod?
          return "http://#{domain_name}.shop/order-cancel" if Rails.env.staging?
          return "http://#{domain_name}.shop/order-cancel" if Rails.env.staging_v2?
          return "http://#{domain_name}.net/order-cancel" if Rails.env.pre_prod_v2?

          'http://localhost:3000/order-cancel'
        end

        def domain_name
          if Rails.env.pre_prod_v2? || Rails.env.staging_v2?
            return context.sub_domain.present? ? "#{sub_domain}.shopoth" : 'v2.shopoth'
          end

          context.sub_domain.present? ? "#{sub_domain}.shopoth" : 'shopoth'
        end
      end
    end
  end
end
