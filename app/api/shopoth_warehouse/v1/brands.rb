module ShopothWarehouse
  module V1
    class Brands < ShopothWarehouse::Base
      resource :brands do

        helpers do
          def skip_action(action = '')
            @request.path.include?(action)
          end

          def fetch_brands(params, brands)
            if params[:title].present? && params[:is_own_brand].to_s.present?
              brands.where(is_own_brand: params[:is_own_brand]).filter_by(params[:title]).order(id: :desc)
            elsif params[:title].present?
              brands.filter_by(params[:title]).order(id: :desc)
            elsif params[:is_own_brand].to_s.present?
              brands.where(is_own_brand: params[:is_own_brand]).order(id: :desc)
            else
              brands.order(id: :desc)
            end
          end
        end

        before do
          unless skip_action('search')
            unless check_wh_warehouse
              error!(failure_response_with_json('Only central admin can see Brand list.',
                                                HTTP_CODE[:FORBIDDEN]), HTTP_CODE[:OK])
            end
          end
        end

        namespace :search do
          # brands/search?name=?
          desc 'Search brand with specific name'
          params do
            optional :name, type: String
          end
          route_setting :authentication, optional: true
          get '/' do
            brands = Brand.filter_by(params[:name])
            unless brands
              error!(respond_with_json('Brand not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end

            case params.has_key?(:promo)
            when true
              present brands, with: ShopothWarehouse::V1::Entities::BrandDetails
            else
              brands = ShopothWarehouse::V1::Entities::Brands.represent(brands)
              success_response_with_json('Brand fetched successfully', HTTP_CODE[:OK], brands)
            end
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to fetch Brand details due to: #{error.message}"
            failure_response_with_json('Unable to fetch Brand details.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        # INDEX *************************************************
        desc 'Get all Brands.'
        get do
          brands = ShopothWarehouse::V1::Entities::Brands.represent(Brand.order(id: :desc))
          success_response_with_json('Brands fetched successfully', HTTP_CODE[:OK], brands)

        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch Brands due to: #{error.message}"
          failure_response_with_json('Unable to fetch Brands.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # Paginated Brand list *************************************************
        desc 'Get all Brands with pagination.'
        params do
          optional :title, type: String
          optional :is_own_brand, type: Boolean
          use :pagination, per_page: 50
        end
        get '/paginated' do
          # TODO: Need to Optimize Query
          brands = ShopothWarehouse::V1::Entities::Brands.represent(
            paginate(Kaminari.paginate_array(fetch_brands(params, Brand.all))),
          )
          success_response_with_json('Brands fetched successfully', HTTP_CODE[:OK], brands)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch Brands due to: #{error.message}"
          failure_response_with_json('Unable to fetch Brands.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # Specific Brand details *************************************************
        desc 'Get a specific Brand.'
        get ':id' do
          brand = Brand.find_by(id: params[:id])
          unless brand
            error!(respond_with_json('Brand not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          brand = ShopothWarehouse::V1::Entities::Brands.represent(brand)
          success_response_with_json('Brand fetched successfully', HTTP_CODE[:OK], brand)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch Brand details due to: #{error.message}"
          failure_response_with_json('Unable to fetch Brand details.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # CREATE ************************************************
        desc 'Create a new Brand.'
        params do
          requires :brand, type: Hash do
            requires :name, type: String
            requires :bn_name, type: String
            optional :is_own_brand, type: Boolean
            optional :brand_info_visible, type: Boolean
            optional :public_visibility, type: Boolean
            optional :homepage_visibility, type: Boolean
            optional :logo_file
            optional :banners_file
            optional :branding_layout, type: String
            optional :branding_promotion_with, type: String
            optional :branding_video_url, type: String
            optional :branding_image_file
            optional :branding_title, type: String
            optional :branding_title_bn, type: String
            optional :branding_subtitle, type: String
            optional :branding_subtitle_bn, type: String
            optional :short_description, type: String
            optional :short_description_bn, type: String
            optional :more_info_button_text, type: String
            optional :more_info_button_text_bn, type: String
            optional :more_info_url, type: String
            optional :redirect_url, type: String
            requires :slug, type: String
            optional :campaigns_attributes, type: Array do
              requires :title, type: String
              requires :title_bn, type: String
              requires :page_url, type: String
            end
            optional :filtering_options_attributes, type: Array do
              requires :filtering_type, type: String
              optional :filtering_keys, type: Array
            end
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
          brand = params[:brand].merge!(created_by_id: @current_staff.id)
          if brand[:campaigns_attributes].present?
            brand[:campaigns_attributes] = brand[:campaigns_attributes]&.map do |ca|
              ca.merge!(created_by_id: @current_staff.id)
            end
          end
          Brand.create!(brand)
          success_response_with_json('Brand created successfully', HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create Brand due to: #{error.message}"
          failure_response_with_json("Unable to create Brand: #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # UPDATE ************************************************
        desc 'Update a specific Brand.'
        put ':id' do
          brand = Brand.find_by(id: params[:id])
          unless brand
            error!(failure_response_with_json('Brand not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end
          if params[:brand][:meta_datum_attributes].present?
            meta_datum_id = brand.meta_datum&.id
            params[:brand][:meta_datum_attributes] = params[:brand][:meta_datum_attributes].merge(id: meta_datum_id)
          end
          brand.update!(params[:brand])
          brand = ShopothWarehouse::V1::Entities::Brands.represent(brand)
          success_response_with_json('Brand updated successfully', HTTP_CODE[:OK], brand)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to update Brand due to: #{error.full_message}"
          error!(failure_response_with_json("Unable to update Brand du to #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        # DELETE ************************************************
        desc 'Delete a specific Brand.'
        delete ':id' do
          brand = Brand.find_by(id: params[:id])
          unless brand
            error!(respond_with_json('Brand not found', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          if brand.products.present?
            error!(failure_response_with_json("This brand has product so can't delete.",
                                              HTTP_CODE[:FORBIDDEN]), HTTP_CODE[:OK])
          else
            response = Thanos::Brand.delete(brand)
            if response[:error].present?
              error!(respond_with_json("Product attribute error response: #{response[:error_descrip]}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
            brand.update(is_deleted: true)
            respond_with_json('Successfully deleted', HTTP_CODE[:OK])
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to update Brand due to: #{error.message}"
          error!(respond_with_json('Unable to delete', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc "Delete a specific Brand's banner."
        params do
          requires :brand_id, type: Integer
        end
        delete ':id/delete_banner' do
          attachment = ActiveStorage::Attachment.find_by(id: params[:id], record_id: params[:brand_id], record_type: 'Brand')
          unless attachment
            error!(failure_response_with_json("Brand's banner image not found.", HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          attachment.destroy!
          success_response_with_json("Successfully deleted brand's banner image.", HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to delete brand's banner image due to: #{error.message}"
          error!(failure_response_with_json("Unable to delete brand's banner image.",
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
