# frozen_string_literal: true

module ImageVersions
  extend ActiveSupport::Concern

  included do
    # TODO: define new sizes here
    def self.sizes
      {
        homepage_banner: { resize_to_fill: [1440, 600] },
        app_homepage_banner: { resize_to_fill: [800, 333] },
        product_small: { resize_to_fill: [100, 100] },
        product_medium: { resize_to_fill: [400, 400] },
        product_large: { resize_to_fill: [1000, 1000] },
        brand_box: { resize_to_fill: [864, 400] },
        logo: { resize_to_fill: [300, 300] }, # (brand_logo, category) image size
        slider_banner: { resize_to_fill: [1060, 360] },
        ad_banner: { resize_to_fill: [330, 360] },
        mini: { resize_to_fill: [48, 48] },
        small: { resize_to_fill: [100, 100] }, # product_small
        product: { resize_to_fill: [240, 240] },
        app_profile: { resize_to_fill: [300, 300] },
        web_profile: { resize_to_fill: [500, 500] },
        large: { resize_to_fill: [1440, 400] }, # (normal_banner, brand_banner, brand_full) image size
        medium: { resize_to_fill: [400, 400] }, # product_medium image size
        web_thumb: { resize_to_fill: [300, 300] }, # product_thumb image size, product listing page hero image
        app_thumb: { resize_to_fill: [300, 300] }, # product_thumb image size, product listing page hero image
        app_general_banner: { resize_to_fill: [800, 222] }, # Slider images for app
        web_general_banner: { resize_to_fill: [1440, 400] }, # Homepage common slider
        app_category: { resize_to_fill: [120, 100] }, # App category logo
        web_category: { resize_to_fill: [300, 300] }, # Web category logo
        web_brand_logo: { resize_to_fill: [300, 300] }, # Web brand logo
        app_brand_logo: { resize_to_fill: [100, 100] }, # App brand logo
        web_brand_banner: { resize_to_fill: [1400, 400] }, # Web brand banner
        app_brand_banner: { resize_to_fill: [100, 100] }, # App brand banner
        web_full_branding_image: { resize_to_fill: [1440, 400] }, # Web full branding image
        web_box_branding_image: { resize_to_fill: [800, 500] }, # Web box branding image
        app_full_branding_image: { resize_to_fill: [400, 400] }, # App full branding image
        app_box_branding_image: { resize_to_fill: [400, 400] }, # App box branding image
        app_coupon_image: { resize_to_fill: [500, 750] }, # App coupon branding image
        web_coupon_image: { resize_to_fill: [200, 50] }, # Web coupon branding image
      }
    end
  end
end
