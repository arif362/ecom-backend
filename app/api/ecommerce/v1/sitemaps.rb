# frozen_string_literal: true

module Ecommerce
  module V1
    class Sitemaps < Ecommerce::Base
      resource :sitemaps do

        desc 'Fetch sitemaps'
        params do
          requires :file_name, type: String
        end
        route_setting :authentication, optional: true
        get '/' do

          config = {region: ENV["AWS_S3_REGION"], bucket: ENV["AWS_S3_BUCKET"], key: ENV['AWS_ACCESS_KEY_ID'], secret: ENV['AWS_SECRET_ACCESS_KEY']}
          Aws.config.update({region: config[:region], credentials: Aws::Credentials.new(config[:key], config[:secret]), s3: { region: ENV["AWS_S3_REGION"] }})
          bucket = Aws::S3::Resource.new.bucket(config[:bucket])

          file = params[:file_name].to_s
          if bucket.object("sitemaps/#{file}").exists?
            path = Rails.root.join('public', 'sitemaps', params[:file_name].to_s)
            bucket.object("sitemaps/#{file}").get({response_target: path})
            request_body = if File.exists?(path)
                             File.open(path).read
                           else
                             []
                           end
            success_response_with_json('Successfully Fetch', HTTP_CODE[:OK], request_body)
          else
            path = Rails.root.join('public', 'sitemaps', params[:file_name].to_s)
            request_body = if File.exists?(path)
                             File.open(path).read
                           else
                             []
                           end
            if request_body.empty?
              error!(failure_response_with_json('Content not found.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            else
              success_response_with_json('Successfully Fetch', HTTP_CODE[:OK], request_body)
            end
          end

          # path = Rails.root.join('public', 'sitemaps', params[:file_name].to_s)
          # request_body = if File.exists?(path)
          #                  File.open(path).read
          #                else
          #                  []
          #                end
          #
          # if request_body.empty?
          #   error!(failure_response_with_json('Content not found.', HTTP_CODE[:NOT_FOUND]),
          #          HTTP_CODE[:NOT_FOUND])
          # end
          #
          # success_response_with_json('Successfully Fetch', HTTP_CODE[:OK], request_body)
        rescue StandardError => error
          Rails.logger.info "articles fetch error #{error.message}"
          error!(failure_response_with_json('Failed to fetch', HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                 HTTP_CODE[:OK])
        end


      end
    end
  end
end



