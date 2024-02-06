module ShopothWarehouse
  module V1
    class AuditLogs < ShopothWarehouse::Base
      resource :audit_logs do
        desc 'Return audit log list with filter'
        params do
          use :pagination, per_page: 50
          optional :created_at, type: Date
          optional :auditable_id, type: Integer
          optional :action, type: String, values: %w(create update destroy)
          optional :auditable_type, type: String, values: %w(Brand Category Coupon CustomerOrder DhPurchaseOrder
                                                             Product Promotion Location
                                                             ReturnTransferOrder Supplier SuppliersVariant
                                                             Variant WhPurchaseOrder Rider Partner
                                                             RetailerAssistant Article AttributeSet
                                                             AttributeSetProductAttribute LineItem
                                                             BankAccount BankTransaction BlockedItem Box
                                                             Campaign Challan Distributor
                                                             DistributorMargin District FailedQc HelpTopic
                                                             MetaDatum PartnerMargin ProductAttribute
                                                             ProductCategory ProductFeature ProductType
                                                             ProductsProductType PromoBanner PromoCoupon
                                                             PromotionVariant PurchaseOrderStatus ReturnChallan
                                                             ReturnCustomerOrder ReturnStatusChange Route RouteDevice
                                                             Slide SocialLink UserModificationRequest
                                                             UserModifyReason WarehouseBundle WarehouseVariant)

        end
        get do
          unless check_wh_warehouse
            error!(failure_response_with_json('Audit log visible for central admin',
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])

          end
          audit_logs = Audited::Audit.where(auditable_type: %w(Brand Coupon DhPurchaseOrder
                                                               WhPurchaseOrder ReturnTransferOrder
                                                               Location Promotion Supplier Variant Product))
          created_at = params[:created_at].present? ? params[:created_at] : nil
          audit_logs = audit_logs.where('DATE(created_at) = ?', created_at) if created_at.present?
          audit_logs = audit_logs.where(auditable_type: params[:auditable_type]) if params[:auditable_type].present?
          audit_logs = audit_logs.where(auditable_id: params[:auditable_id]) if params[:auditable_id].present?
          audit_logs = audit_logs.where(action: params[:action]) if params[:action].present?
          unless audit_logs
            error!(failure_response_with_json('Audit log not found',
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])

          end
          # TODO: Need to Optimize Query
          success_response_with_json('Successfully fetched audit log', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::AuditLogs.represent(
                                       paginate(Kaminari.paginate_array(audit_logs.order(id: :desc)))))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch audit log due to, #{error.message}"
          error!(failure_response_with_json('Unable to fetch audit log', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Show Details of a specific audit log.'
        get ':id' do
          unless check_wh_warehouse
            error!(failure_response_with_json('Audit log visible for central admin',
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])

          end

          success_response_with_json('Successfully fetched audit log', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::AuditLogs.represent(Audited::Audit.find_by(id: params[:id])))
        rescue StandardError => error
          Rails.logger.info "#{__FILE__} \nUnable to fetch audit log #{error.message}"
          error!(respond_with_json("Unable to fetch audit log #{error.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end


        desc 'Return audit log for a variant'
        params do
          use :pagination, per_page: 50
          requires :variant_id, type: Integer
        end
        get '/inventory' do
          unless check_wh_warehouse
            error!(failure_response_with_json('Audit log visible for central admin',
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])

          end
          # TODO: Need to Optimize Query
          audit_logs = paginate(Kaminari.paginate_array(Variant.find_by(id: params[:variant_id])&.audits.order(id: :desc)))
          unless audit_logs
            error!(failure_response_with_json('Audit log not found',
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])

          end
          success_response_with_json('Successfully fetched inventory audit log', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::InventoryAuditLog.represent(audit_logs))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch inventory audit log due to, #{error.message}"
          error!(failure_response_with_json('Unable to fetch inventory audit log', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
