# frozen_string_literal: true
module Ecommerce::V1::Serializers
  module FooterSerializer
    extend Grape::API::Helpers
    def footer_important_links(links)
      Jbuilder.new.links do |json|
        json.array! links do |link|
          json.title link.title
          json.view_url show_page_url(link.id)
        end
      end
    end

    def show_page_url(id)
      "/shop/api/v1/#{id}"
    end

    def footer_category(categories)
      Jbuilder.new.categories do |json|
        json.array! categories do |category|
          json.title category.title
          json.bn_title category.bn_title
          json.view_url show_category_page(category.id)
        end
      end
    end

    def show_category_page(id)
      "/shop/api/v1/product_category/#{id}"
    end
  end
end
