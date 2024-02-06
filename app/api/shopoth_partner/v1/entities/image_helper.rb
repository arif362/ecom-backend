# frozen_string_literal: true
module ShopothPartner::V1::Helpers
  module ImageHelper
    extend Grape::API::Helpers
    include Rails.application.routes.url_helpers

    def image_path(obj)
      obj.service_url if obj.attached?
    end

    def image_paths(img_arr)
      if img_arr.attached?
        img_arr.map(&:service_url)
      end
    end

    def image_variant_path(obj)
      if obj.attached?
        {
          mini_img: obj&.variant(Product&.sizes[:mini])&.processed&.service_url,
          small_img: obj&.variant(Product&.sizes[:small])&.processed&.service_url,
          product_img: obj&.variant(Product&.sizes[:product])&.processed&.service_url,
          large_img: obj&.variant(Product&.sizes[:large])&.processed&.service_url,
        }
      end
    end

    def image_variant_paths(img_arr)
      img_arr.map do |obj|
        {
          mini_img: request.base_url + Product.get_img_url('mini', obj),
          small_img: request.base_url + Product.get_img_url('small', obj),
          product_img: request.base_url + Product.get_img_url('product', obj),
          large_img: request.base_url + Product.get_img_url('large', obj),
        }
      end
    end
  end
end
