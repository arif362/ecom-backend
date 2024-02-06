module ShopothWarehouse
  module V1
    class StaticPages < ShopothWarehouse::Base
      resource :static_pages do
        get '/page_types' do
          page_types = StaticPage.page_types.map{|k, v| {title:k.titleize, value:v}}

          success_response_with_json('Successfully fetch list of page type.', HTTP_CODE[:OK], page_types)
        rescue StandardError => error
          error!(failure_response_with_json("Something went wrong due to #{error.message}.",
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        params do
          requires :page_type, type: Integer
          optional :meta_datum_attributes, type: Hash do
            optional :meta_keyword, type: Array
            optional :bn_meta_keyword, type: Array
            optional :meta_title, type: String
            optional :bn_meta_title, type: String
            optional :meta_description, type: String
            optional :bn_meta_description, type: String
          end
        end

        desc 'create a new Static Page'
        post do
          static_page = StaticPage.new(params)
          static_page.save!
          static_page = ShopothWarehouse::V1::Entities::StaticPages.represent(static_page)
          success_response_with_json("Successfully Create #{static_page.page_type&.titleize}.", HTTP_CODE[:OK], static_page)
        rescue StandardError => error
          error!(failure_response_with_json("Unable to create page due to #{error.message}.",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Update a Static Page'
        route_param :id do
          put do
            static_page = StaticPage.find(params[:id])
            unless static_page
              error!(failure_response_with_json('Page not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end
            meta_datum_id = static_page.meta_datum&.id
            params[:meta_datum_attributes] = params[:meta_datum_attributes].merge(id: meta_datum_id)
            static_page.update!(params)
            static_page = ShopothWarehouse::V1::Entities::StaticPages.represent(static_page)
            success_response_with_json("Successfully updated #{static_page.page_type&.titleize}.", HTTP_CODE[:OK], static_page)
          rescue StandardError => error
            error!(failure_response_with_json("Unable to update page  with id #{params[:id]} due to #{error.message}.",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
        end

        desc 'Delete a specific Static Page'
        route_param :id do
          delete do
            static_page = StaticPage.find(params[:id])
            static_page.destroy!
            static_page = ShopothWarehouse::V1::Entities::StaticPages.represent(static_page)
            success_response_with_json('Successfully Deleted Static Page.', HTTP_CODE[:OK], static_page)
          rescue StandardError => error
            error!(failure_response_with_json(error, HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
        end

        desc 'Return list of static page'
        get do
          list = StaticPage.all
          static_pages = ShopothWarehouse::V1::Entities::StaticPageList.represent(list)
          success_response_with_json('Successfully Fetch Static Pages.', HTTP_CODE[:OK], static_pages)

        rescue StandardError => error
          error!(failure_response_with_json(error, HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Return a details of static page'
        get ':id' do
          static_page = StaticPage.find(params[:id])
          if static_page.present?
            static_page = ShopothWarehouse::V1::Entities::StaticPages.represent(static_page)
            success_response_with_json('Successfully Fetch Static Page.', HTTP_CODE[:OK], static_page)
          else
            error!(failure_response_with_json('Static Page not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end
        rescue StandardError => error
          error!(failure_response_with_json(error, HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
