module ShopothWarehouse
  module V1
    class Slides < ShopothWarehouse::Base
      resource :slides do
        desc 'List all sliders'
        get do
          present Slide.all, with: ShopothWarehouse::V1::Entities::Slide
        end

        desc 'Get all image_type of Slide.'
        get 'image_type' do
          success_response_with_json('Successfully fetched image types.', HTTP_CODE[:OK], Slide.img_types)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch slider image types due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch slider image types.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        params do
          requires :name, type: String
          requires :link_url, type: String, desc: 'Link to the content of the slider'
          requires :image
          requires :published, type: Boolean
          requires :img_type, type: Integer
          optional :body, type: String
          optional :position, type: Integer, desc: 'Sliding order e.g., 1 , 2 , 3...'
        end

        desc 'Create a slider'
        post do
          error! respond_with_json('Image is missing!', HTTP_CODE[:NOT_FOUND]) unless params[:image].present?
          declared_params = declared(params, include_missing: false)
          declared_params.merge!(created_by_id: @current_staff.id)
          slide = Slide.new(declared_params)
          slide.attachment(params[:image]) if params[:image].present?
          present slide, with: ShopothWarehouse::V1::Entities::Slide if slide.save
        rescue StandardError => error
          error! respond_with_json "Could not save slider #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]
        end

        route_param :id do
          helpers do
            def slider
              @slider ||= Slide.find(params[:id])
            end
          end

          desc 'Get a slider'
          get do
            present slider, with: ShopothWarehouse::V1::Entities::Slide
          end

          desc 'Update a slider'
          params do
            optional :name, type: String
            optional :link_url, type: String, desc: 'Link to the content of the slider'
            optional :image
            optional :published, type: Boolean
            optional :img_type, type: Integer
            optional :body, type: String
            optional :position, type: Integer, desc: 'Sliding order e.g., 1 , 2 , 3...'
          end

          put do
            declared_params = declared(params, include_missing: false)
            slider.update! declared_params.except(:image)
            slider.attachment(params[:image]) if params[:image].present?
            present slider, with: ShopothWarehouse::V1::Entities::Slide

          rescue StandardError => error
            error! respond_with_json "Unable to update slider because #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]
          end

          desc 'Delete a slider'
          delete do
            unless check_wh_warehouse
              error!(respond_with_json('Not permitted to delete', HTTP_CODE[:FORBIDDEN]),
                     HTTP_CODE[:FORBIDDEN])
            end
            slide = Slide.find_by(id: params[:id])
            unless slide.present?
              error!(respond_with_json('Slide not found', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
            respond_with_json('Successfully deleted', HTTP_CODE[:OK]) if slide.destroy!
          rescue StandardError => error
            Rails.logger.info "Unable to delete #{error.message}"
            error!(respond_with_json('Unable to delete', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
