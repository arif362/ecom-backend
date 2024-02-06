module Ecommerce::V1::Serializers
  module HomepageSerializer
    extend Grape::API::Helpers
    include Ecommerce::V1::Helpers::ImageHelper

    def image_path(obj)
      rails_public_blob_url(obj) if obj.attached?
    end

    def to_slider_json(sliders)
      Jbuilder.new.sliders do |json|
        json.array! sliders do |slider|
          json.name slider.name
          json.body slider.body
          json.link_url slider.link_url
          json.position slider.position
          json.img_type slider.img_type
          if slider.app_coupon_slider? || slider.web_coupon_slider?
            json.slider_url coupon_slider_image_url(slider.image)
          else
            json.slider_url slider.homepage_slider? ? homepage_slider_image_url(slider.image) : banner_image_url(slider.image)
          end
        end
      end
    end

    def get_homepage_product_list(products, current_user = '', warehouse = '')
      Jbuilder.new.key do |json|
        json.array! products do |product|
          brand = product.brand
          min_variant = product.min_emrp_variant
          json.id product.id
          json.title product.title
          json.bn_title product.bn_title
          json.image_url thumb_product_image_path(product.hero_image)
          # TODO: Product view url
          json.view_url get_product_show_url(product.id)
          json.price product.get_product_base_price.to_i
          json.discount product.discount.to_s
          json.discount_stringified product.discount_stringify
          json.effective_mrp product.discounted_price.to_i
          json.brand_id brand&.id
          json.brand_name brand&.name
          json.brand_name_bn brand&.bn_name
          json.variant_id min_variant&.id
          json.is_wishlisted min_variant&.wishlisted?(current_user)
          json.badge product&.promo_tag
          json.bn_badge product&.bn_promo_tag
          json.slug product.slug
          json.sell_count product.sell_count
          json.max_quantity_per_order product.max_quantity_per_order
          json.sku_type product.sku_type
          json.available_quantity product.product_available_quantity(warehouse)
          json.is_available product.product_available_quantity(warehouse).positive? || false
          json.is_requested min_variant&.is_requested?(current_user, warehouse) || false
        end
      end
    end

    def get_product_search_json(products)
      Jbuilder.new.key do |json|
        json.array! products do |product|
          json.id product.id
          json.title product.title
          json.mini_img product.master_img('mini')
          json.image_url product.master_img('product')
          json.price product.get_product_base_price.to_i
          json.view_url get_product_show_url(product.id)
          json.discount product.discount
          json.discount_stringified product.discount_stringify
          json.effective_mrp product.discounted_price.to_i
        end
      end
    end

    def get_product_show_url(id)
      "/products/details/#{id}"
    end

    # Get menu
    def menu_category(lists)
      Jbuilder.new.key do |json|
        json.array! lists do |list|
          json.id list.id
          json.title list.title
          json.bn_title list.bn_title
          json.slug list.slug
          json.image image_path(list.image)
          json.sub_categories list.sub_categories.where(home_page_visibility: true).order(:position).includes(:sub_categories) do |sub_category|
            json.id sub_category.id
            json.title sub_category.title
            json.bn_title sub_category.bn_title
            json.slug sub_category.slug
            json.view_url get_category_url(sub_category.slug)
            json.sub_categories sub_category.sub_categories.where(home_page_visibility: true).order(:position) do |sub_cat|
              json.id sub_cat.id
              json.title sub_cat.title
              json.bn_title sub_cat.bn_title
              json.slug sub_cat.slug
              json.view_url get_category_url(sub_cat.slug)
            end
          end
        end
      end
    end

    # Get shop_by_category
    def get_shop_by_category(categories)
      Jbuilder.new.key do |json|
        json.array! categories do |category|
          json.id category.id
          json.title category.title
          json.bn_title category.bn_title
          json.image category_image_path(category.image)
          json.view_url get_category_url(category.slug)
          json.slug category.slug
        end
      end
    end

    def get_category_url(slug)
      "/product_category/#{slug}"
    end

    def get_brand_info(brands)
      Jbuilder.new.key do |json|
        json.array! brands do |brand|
          json.name brand.name
          json.main_image image_path(brand.image)
          json.hover_image image_path(brand.hover_image)
        end
      end
    end

    def flash_sale(flash_sale, current_user, products, warehouse = '')
      Jbuilder.new.key do |json|
        json.id flash_sale.id
        json.title flash_sale.title
        json.bn_title flash_sale.title_bn
        json.start_at flash_sale_time(flash_sale.from_date, flash_sale.start_time)
        json.end_at flash_sale_time(flash_sale.to_date, flash_sale.end_time)
        json.current_date Time.zone.now
        json.active flash_sale.is_active
        json.products get_homepage_product_list(products, current_user, warehouse)
      end
    end

    def flash_sale_time(day, time)
      Time.zone.parse(day.to_s) + Time.zone.parse(time).seconds_since_midnight.seconds
    end
  end
end
