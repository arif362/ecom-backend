module ShopothWarehouse
  module V1
    class Slugs < ShopothWarehouse::Base
      resource :slugs do
        desc 'unique slug check'
        params do
          requires :slug, type: String, allow_blank: false
          optional :id, type: Integer
          optional :type, type: String
        end
        get '/uniqueness' do
          params[:slug] = params[:slug].present? ? params[:slug] : ''
          slug = if params[:id].present? && params[:type].present?
                   FriendlyIdSlug.where.not(sluggable_id: params[:id], sluggable_type: params[:type]).where('LOWER(slug) = ?',
                                                            params[:slug].downcase.to_s.parameterize)
                 else
                   FriendlyIdSlug.where('LOWER(slug) = ?', params[:slug].downcase.to_s.parameterize)
                 end
          if slug.present?
            error!(failure_response_with_json('This slug already exists', HTTP_CODE[:UNPROCESSABLE_ENTITY],
                                              data = {}), HTTP_CODE[:OK])
          else
            success_response_with_json('Slug is unique', HTTP_CODE[:OK], data = {})
          end
        rescue StandardError => error
          Rails.logger.info "Slug uniqueness check failed: #{__FILE__}, line - #{__LINE__} #{error.message}"
          error!(failure_response_with_json(error, HTTP_CODE[:UNPROCESSABLE_ENTITY],
                                            data = {}), HTTP_CODE[:OK])
        end

      end
    end
  end
end
