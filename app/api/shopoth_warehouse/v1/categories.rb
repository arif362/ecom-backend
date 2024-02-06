module ShopothWarehouse
  module V1
    class Categories < ShopothWarehouse::Base
      INVALID = 'invalid record'.freeze

      resource :categories do

        desc 'Category list without pagination'
        get 'tree_details' do
          categories = Category.where(parent_id: nil, home_page_visibility: true).includes(:sub_categories)
          success_response_with_json('Successfully fetched categories', HTTP_CODE[:OK],
            ShopothWarehouse::V1::Entities::CategoriesList.represent(categories.order(created_at: :desc)))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\n Unable to fetch categories due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch categories', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        desc 'Return list of categories.'
        params do
          use :pagination, per_page: 50
        end
        get do
          categories = Category.where(parent_id: nil, home_page_visibility: true).includes(:sub_categories)
          # TODO: Need to Optimize Query
          ShopothWarehouse::V1::Entities::Categories.represent(
            paginate(Kaminari.paginate_array(categories.order(created_at: :desc))),
          )
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\n Unable to fetch categories due to: #{error.message}"
          error!(respond_with_json('Unable to fetch categories.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Return list of categories.'
        params do
          use :pagination, per_page: 50
        end
        get :list do
          categories = Category.where(parent_id: nil, home_page_visibility: true).includes(:sub_categories)
          # TODO: Need to Optimize Query
          ShopothWarehouse::V1::Entities::Categories.represent(
            paginate(Kaminari.paginate_array(categories.order(created_at: :desc))),
          )
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\n Unable to fetch categories due to: #{error.message}"
          error!(respond_with_json('Unable to fetch categories.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Create a new category.'
        params do
          requires :category, type: Hash do
            requires :title, type: String
            requires :slug, type: String
            requires :position, type: Integer
            requires :bn_title, type: String
            optional :description, type: String
            optional :image_file, type: File
            optional :banner_image_file, type: File
            optional :parent_id, type: Integer
            requires :home_page_visibility, type: Boolean
            optional :business_type, type: String, values: Category.business_types.keys
            optional :meta_datum_attributes, type: Hash do
              optional :meta_keyword, type: Array
              optional :bn_meta_keyword, type: Array
              optional :meta_title, type: String
              optional :bn_meta_title, type: String
              optional :meta_description, type: String
              optional :bn_meta_description, type: String
            end
          end
        end

        post do
          unless check_wh_warehouse
            error!(respond_with_json('Only central warehouse can create categories.', HTTP_CODE[:FORBIDDEN]),
                   HTTP_CODE[:FORBIDDEN])
          end

          unless params[:category][:image_file].present?
            error!(respond_with_json('Need to provide category image.', HTTP_CODE[:FORBIDDEN]),
                   HTTP_CODE[:FORBIDDEN])
          end

          unless params[:category][:banner_image_file].present?
            error!(respond_with_json('Need to provide category banner image.',
                                     HTTP_CODE[:FORBIDDEN]), HTTP_CODE[:FORBIDDEN])
          end

          category = Category.new(params[:category].merge!(created_by_id: @current_staff.id))
          category.save!
          present category, with: ShopothWarehouse::V1::Entities::Categories
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create Category due to: #{error.message}"
          error!(respond_with_json("Unable to create category due to: #{error.message}.", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'get a new category'
        params do
          requires :id, type: Integer, desc: 'category id'
        end

        route_param :id do
          get do
            category = Category.find(params[:id])
            # category_json = ApplicationController.render 'api/categories/show', locals: { category: category }
            # JSON.parse(category_json)
            present category, with: ShopothWarehouse::V1::Entities::Categories
          rescue StandardError => e
            error! respond_with_json("Unable to find category with id #{params[:id]} due to #{e.message}",
                                     HTTP_CODE[:NOT_FOUND])
          end
        end

        desc 'Update a specific category'
        route_param :id do
          put do
            category = Category.find(params[:id])

            if params[:category][:meta_datum_attributes].present?
              meta_datum_id = category.meta_datum&.id
              params[:category][:meta_datum_attributes] = params[:category][:meta_datum_attributes].merge(id: meta_datum_id)
            end

            parent_category = category&.parent
            new_parent_category = Category.find(params[:category][:parent_id]) if params[:category][:parent_id]
            category.update!(params[:category].except(:parent_id))
            if new_parent_category.present? && parent_category != new_parent_category && category != new_parent_category
              category.update_product_categories(parent_category, new_parent_category)
            end
            present category, with: ShopothWarehouse::V1::Entities::Categories
          rescue StandardError => e
            error! respond_with_json("Unable to update Category due to #{e.message}.",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'delete a category'
        params do
          requires :id, type: String, desc: 'category id'
        end

        delete ':id' do
          category = Category.find_by(id: params[:id])
          unless category.present?
            error!(respond_with_json('Category not found', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end
          if category.products.present?
            error!(respond_with_json('Sorry unable to delete due to products exist under this category!',
                                     HTTP_CODE[:FORBIDDEN]), HTTP_CODE[:FORBIDDEN])
          else
            respond_with_json('Successfully deleted', HTTP_CODE[:OK]) if category.destroy!
          end

        rescue StandardError => error
          Rails.logger.info "Unable to delete #{error.message}"
          error!(respond_with_json('Unable to delete', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
