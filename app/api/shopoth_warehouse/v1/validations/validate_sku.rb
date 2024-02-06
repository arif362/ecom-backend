module API
  module V1
    module Validations
      class ValidateSku < Grape::Validations::Base
        MESSAGE = 'is already taken'.freeze
        def validate_param!(_attr_name, params)
          skus = params[:variants_attributes].map do |variant|
            variant[:sku]
          end

          if skus.count > 1
            if skus & skus == skus
              skus.each do |sku|
                variants = Variant.where(sku: sku)
                next unless variants.present?

                check_sku_n_raise_error(sku, variants)
              end
            else
              raise_error
            end
          else
            variants = Variant.where(sku: skus.first)
            return unless variants.present?

            check_sku_n_raise_error(skus.first, variants)
          end
        end

        def check_sku_n_raise_error(sku, variants)
          skus = Variant.all.map(&:sku)
          raise_error if skus.include?(sku) && variants.map(&:is_deleted).any?(false)
        end

        def raise_error
          fail Grape::Exceptions::Validation,
               params: ['sku'],
               message: MESSAGE
        end
      end
    end
  end
end
