# frozen_string_literal: true

module Ecommerce::V1::Helpers
  module SliderHelper
    extend Grape::API::Helpers
    params :slider_params do
      requires :name, type: String
      requires :link_url, type: String, desc: 'Link to the content of the slider'
      requires :published, type: Boolean
      requires :img_type, type: Integer
      optional :body, type: String
      optional :position, type: Integer, desc: 'Sliding order e.g., 1 , 2 , 3...'
    end
  end
end


