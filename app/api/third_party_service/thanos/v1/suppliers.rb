# frozen_string_literal: true

module ThirdPartyService
  module Thanos
    module V1
      class Suppliers < Thanos::Base
        resource :suppliers do
          desc 'Assign product to suppliers'
          params do
            requires :supplier_unique_id, type: String
            requires :suppliers_variants, type: Array do
              requires :variant_unique_id, type: String
              requires :supplier_price, type: BigDecimal
            end
          end
          post '/assign_products' do
            supplier = Supplier.find_by(unique_id: params[:supplier_unique_id])
            unless supplier
              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             failure_response_with_json('Supplier not found',
                                                                        HTTP_CODE[:NOT_FOUND]),
                                             @current_staff,
                                             false)
              error!(failure_response_with_json('Supplier not found',
                                                HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:OK])
            end
            params[:suppliers_variants].each do |supplier_variant|
              variant = Variant.find_by(
                unique_id: supplier_variant[:variant_unique_id],
              )
              unless variant.present?
                ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                               failure_response_with_json('Variant not found',
                                                                          HTTP_CODE[:NOT_FOUND]),
                                               @current_staff,
                                               false)
                error!(failure_response_with_json('Variant not found',
                                                  HTTP_CODE[:NOT_FOUND]),
                       HTTP_CODE[:OK])
              end
              next if supplier.suppliers_variants.find_by(variant: variant).present?

              supplier.suppliers_variants.create!(variant: variant,
                                                  supplier_price: supplier_variant[:supplier_price])
              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             success_response_with_json('Successfully assigned product',
                                                                        HTTP_CODE[:OK], {}),
                                             @current_staff,
                                             true)
            end
            success_response_with_json('Successfully assigned product', HTTP_CODE[:CREATED])
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\n Unable to assign product to supplier,#{supplier.id} due to: #{error.full_message}"
            ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                           failure_response_with_json("Unable to assign product to supplier_id: #{supplier.id} due to, #{error.message}",
                                                                      HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                                           @current_staff,
                                           false)
            error!(failure_response_with_json("Unable to assign product to supplier_id: #{supplier.id} due to, #{error.message}",
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:OK])
          end
        end
      end
    end
  end
end
