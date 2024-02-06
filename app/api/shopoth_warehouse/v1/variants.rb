module ShopothWarehouse
  module V1
    class Variants < ShopothWarehouse::Base
      include Grape::Kaminari
      resource :variants do
        desc 'Supplier Variants Changes Log'
        params do
          use :pagination, per_page: 50
        end
        get ':id/supplier_variants_log' do
          supplier_variants = Variant.unscoped.find_by(id: params[:id])&.suppliers_variants
          unless supplier_variants
            Rails.logger.info 'Unable to fetch supplier variant'
            error!(failure_response_with_json('Unable to fetch supplier variant', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end
          # TODO: Need to Optimize Query
          changes_log = paginate(Kaminari.paginate_array(
                                   Audited::Audit.where(auditable_type: 'SuppliersVariant',
                                                        auditable_id: supplier_variants.unscoped.map(&:id)).order(id: :desc)))
          success_response_with_json('Successfully fetched supplier variant changes log', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::AuditLogs.represent(changes_log))
        rescue StandardError => error
          Rails.logger.info "#{__FILE__} \nUnable to fetch supplier variant
                                          changes log due to, #{error.message}"
          error!(failure_response_with_json("Unable to fetch supplier variant
                                            changes log due to, #{error.message}",
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
