# frozen_string_literal: true

module Ecommerce
  module V1
    module Helpers
      module ImageHelper
        extend Grape::API::Helpers
        include Rails.application.routes.url_helpers

        def image_path(obj)
          rails_public_blob_url(obj) if obj.attached?
        end

        def images_paths(obj)
          if obj.attached?
            {
              app_img: obj.variable? ? rails_public_blob_url(obj.variant(Product.sizes[:app_profile])&.processed) : rails_public_blob_url(obj),
              web_img: obj.variable? ? rails_public_blob_url(obj.variant(Product.sizes[:web_profile])&.processed) : rails_public_blob_url(obj),
            }
          else
            {
              app_img: '',
              web_img: '',
            }
          end
        end

        def thumb_product_image_path(obj)
          if @request_source == :app
            obj.variable? ? rails_public_blob_url(obj.variant(Product.sizes[:app_thumb])&.processed) : rails_public_blob_url(obj)
          else
            obj.variable? ? rails_public_blob_url(obj.variant(Product.sizes[:web_thumb])&.processed) : rails_public_blob_url(obj)
          end
        rescue
          Rails.logger.error 'Image not found.'
          ''
        end

        def slider_image_path(obj)
          if @request_source == :app
            obj.variable? ? rails_public_blob_url(obj.variant(Product.sizes[:app_general_banner])&.processed) : rails_public_blob_url(obj)
          else
            obj.variable? ? rails_public_blob_url(obj.variant(Product.sizes[:web_general_banner])&.processed) : rails_public_blob_url(obj)
          end
        end

        def category_image_path(obj)
          if @request_source == :app
            obj.variable? ? rails_public_blob_url(obj.variant(Product.sizes[:app_category])&.processed) : rails_public_blob_url(obj)
          else
            obj.variable? ? rails_public_blob_url(obj.variant(Product.sizes[:web_category])&.processed) : rails_public_blob_url(obj)
          end
        end

        def brand_logo_image_path(obj)
          if @request_source == :app
            obj.variable? ? rails_public_blob_url(obj.variant(Product.sizes[:app_brand_logo])&.processed) : rails_public_blob_url(obj)
          else
            obj.variable? ? rails_public_blob_url(obj.variant(Product.sizes[:web_brand_logo])&.processed) : rails_public_blob_url(obj)
          end
        end

        def category_banner_image_path(obj, request_source = nil)
          @request_source ||= request_source
          if @request_source == :app
            obj.variable? ? rails_public_blob_url(obj.variant(Product.sizes[:app_general_banner])&.processed) : rails_public_blob_url(obj)
          else
            obj.variable? ? rails_public_blob_url(obj.variant(Product.sizes[:web_general_banner])&.processed) : rails_public_blob_url(obj)
          end
        end

        def brand_banner_image_paths(image_arr, request_source = nil)
          @request_source ||= request_source
          if @request_source == :app
            image_arr.map do |image|
              image.variable? ? rails_public_blob_url(image.variant(Product.sizes[:app_general_banner])&.processed) : rails_public_blob_url(image)
            end
          else
            image_arr.map do |image|
              image.variable? ? rails_public_blob_url(image.variant(Product.sizes[:web_general_banner])&.processed) : rails_public_blob_url(image)
            end
          end
        end

        def brand_full_branding_image_path(obj)
          if @request_source == :app
            obj.variable? ? rails_public_blob_url(obj.variant(Product.sizes[:app_full_branding_image])&.processed): rails_public_blob_url(obj)
          else
            obj.variable? ? rails_public_blob_url(obj.variant(Product.sizes[:web_full_branding_image])&.processed) : rails_public_blob_url(obj)
          end
        end

        def brand_box_branding_image_path(obj)
          if @request_source == :app
            obj.variable? ? rails_public_blob_url(obj&.variant(Product.sizes[:app_box_branding_image])&.processed) : rails_public_blob_url(obj)
          else
            obj.variable? ? rails_public_blob_url(obj.variant(Product.sizes[:web_box_branding_image])&.processed) : rails_public_blob_url(obj)
          end
        end

        def image_paths(img_arr)
          if img_arr.attached?
            new_arr = []
            img_arr.each do |img|
              path = rails_public_blob_url(img)
              new_arr << path
            end
            new_arr
          end
        end

        def image_variants_path(img_arr)
          if img_arr.attached?
            new_arr = []
            img_arr.each do |img|
              image_hash = {
                small_img: img.variable? ? rails_public_blob_url(img.variant(Product.sizes[:small])&.processed) : rails_public_blob_url(img),
                large_img: img.variable? ? rails_public_blob_url(img.variant(Product.sizes[:large])&.processed) : rails_public_blob_url(img),
              }
              new_arr << image_hash
            rescue
              image_hash = {
                small_img: '',
                large_img: '',
              }
              new_arr << image_hash
            end
            new_arr
          end
        end

        def image_variant_path(obj)
          if obj.attached?
            {
              mini_img: obj.variable? ? rails_public_blob_url(obj.variant(Product.sizes[:mini])&.processed) : rails_public_blob_url(obj),
              small_img: obj.variable? ? rails_public_blob_url(obj.variant(Product.sizes[:small])&.processed) : rails_public_blob_url(obj),
              product_img: obj.variable? ? rails_public_blob_url(obj.variant(Product.sizes[:product])&.processed) : rails_public_blob_url(obj),
              large_img: obj.variable? ? rails_public_blob_url(obj.variant(Product.sizes[:large])&.processed) : rails_public_blob_url(obj),
            }
          end
        end

        def thumb_image(obj)
          obj.variable? ? rails_public_blob_url(obj.variant(Product.sizes[:thumb])&.processed) : rails_public_blob_url(obj) if obj.attached?
        rescue
          ''
        end

        def image_variant_paths(img_arr)
          new_arr = []
          img_arr.each do |obj|
            new_arr << {
              mini_img: request.base_url + Product.get_img_url('mini', obj),
              small_img: request.base_url + Product.get_img_url('small', obj),
              product_img: request.base_url + Product.get_img_url('product', obj),
              large_img: request.base_url + Product.get_img_url('large', obj),
            }
          end
        end

        def product_details_hero_image(image)
          {
            small_img: image.variable? ? rails_public_blob_url(image.variant(Product.sizes[:product_small])&.processed) || '' : rails_public_blob_url(image),
            medium_img: image.variable? ? rails_public_blob_url(image.variant(Product.sizes[:product_medium])&.processed) || '' : rails_public_blob_url(image),
            large_img: image.variable? ? rails_public_blob_url(image.variant(Product.sizes[:product_large])&.processed) || '' : rails_public_blob_url(image),
          }
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nHero image not found due to: #{error.message}"
          {
            small_img: '',
            medium_img: '',
            large_img: '',
          }
        end

        def product_details_product_images(image_array)
          image_array&.map do |image|
            {
              small_img: image.variable? ? rails_public_blob_url(image.variant(Product.sizes[:product_small])&.processed) : rails_public_blob_url(image),
              medium_img: image.variable? ? rails_public_blob_url(image.variant(Product.sizes[:product_medium])&.processed) : rails_public_blob_url(image),
              large_img: image.variable? ? rails_public_blob_url(image.variant(Product.sizes[:product_large])&.processed) : rails_public_blob_url(image),
            }
          rescue StandardError
            {
              small_img: '',
              medium_img: '',
              large_img: '',
            }
          end
        end

        def product_details_attribute_image(image)
          {
            small_img: image.variable? ? rails_public_blob_url(image.variant(Product.sizes[:product_small])&.processed) : rails_public_blob_url(image),
            medium_img: image.variable? ? rails_public_blob_url(image.variant(Product.sizes[:product_medium])&.processed) : rails_public_blob_url(image),
            large_img: image.variable? ? rails_public_blob_url(image.variant(Product.sizes[:product_large])&.processed) : rails_public_blob_url(image),
          }
        rescue StandardError
          {
            small_img: '',
            medium_img: '',
            large_img: '',
          }
        end

        def homepage_slider_image_url(obj)
          if @request_source == :app
            obj.variable? ? rails_public_blob_url(obj.variant(Slide.sizes[:app_homepage_banner]).processed) : rails_public_blob_url(obj)
          else
            obj.variable? ? rails_public_blob_url(obj.variant(Slide.sizes[:homepage_banner]).processed) : rails_public_blob_url(obj)
          end
        rescue StandardError => error
          ''
        end

        def coupon_slider_image_url(obj)
          if @request_source == :app
            obj.variable? ? rails_public_blob_url(obj.variant(Slide.sizes[:app_coupon_image]).processed) : rails_public_blob_url(obj)
          else
            obj.variable? ? rails_public_blob_url(obj.variant(Slide.sizes[:web_coupon_image]).processed) : rails_public_blob_url(obj)
          end
        rescue StandardError => error
          ''
        end

        def banner_image_url(obj)
          if @request_source == :app
            obj.variable? ? rails_public_blob_url(obj.variant(Slide.sizes[:app_homepage_banner]).processed) || '' : rails_public_blob_url(obj)
          else
            obj.variable? ? rails_public_blob_url(obj.variant(Slide.sizes[:homepage_banner]).processed) || '' : rails_public_blob_url(obj)
          end
        rescue StandardError => error
          ''
        end
      end
    end
  end
end
