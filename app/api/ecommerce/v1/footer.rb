# frozen_string_literal: true

module Ecommerce
  module V1
    class Footer < Ecommerce::Base
      helpers Ecommerce::V1::Serializers::FooterSerializer
      namespace 'footer' do
        desc 'get all footer information'
        route_setting :authentication, optional: true
        get do
          store_info = StoreInfo.select(:contact_address, :contact_number, :official_email).last
          important_link = footer_important_links StaticPage.get_important_link
          categories = footer_category Category.get_categories
          social_link = SocialLink.select(:id, :name, :url).order(:name)
          # TODO: pick all credit, debit, visa card images
          { categories: categories,
            contact_address: store_info,
            important_link: important_link,
            social_link: social_link, }
        rescue StandardError => ex
          respond_with_json("Something went wrong due to #{ex.message}", 500)
        end

        desc 'Article list'
        route_setting :authentication, optional: true
        get '/articles' do
          articles = Article.published.where(footer_visibility: true).order(position: :asc, title: :asc)
          success_response_with_json('Successfully Fetch', HTTP_CODE[:OK],
                                     Ecommerce::V1::Entities::Articles.represent(articles))
        rescue StandardError => error
          Rails.logger.info "articles fetch error #{error.message}"
          error!(failure_response_with_json('Failed to fetch', HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                 HTTP_CODE[:OK])
        end
      end
    end
  end
end
