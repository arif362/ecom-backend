# frozen_string_literal: true
module Ecommerce::V1::Helpers
  module NumberHelper
    extend Grape::API::Helpers

    def format_number(num)
      return num.to_i unless I18n.locale == :bn

      final_string = ''
      arr = num.to_i.to_s.chars.map(&:to_i)
      arr.each do |n|
        final_string +=  I18n.t("number.#{n}")
      end
      final_string
    end
  end
end
