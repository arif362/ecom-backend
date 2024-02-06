module ShopothWarehouse
  module V1
    module Entities
      class Suppliers < Grape::Entity
        expose :id
        expose :phone
        expose :status
        expose :created_at
        expose :updated_at
        expose :delivery_type
        expose :is_deleted
        expose :mou_document_number
        expose :supplier_name
        expose :supplier_representative
        expose :representative_designation
        expose :representative_contact
        expose :tin
        expose :bin
        expose :contract_start_date
        expose :contract_end_date
        expose :bank_name
        expose :account_number
        expose :swift_code
        expose :central_warehouse_address
        expose :local_warehouse_address
        expose :pre_payment
        expose :product_quality_rating
        expose :deliver_time_rating
        expose :service_quality_rating
        expose :professionalism_rating
        expose :post_payment
        expose :credit_payment
        expose :credit_days
        expose :credit_limit
        expose :agami_kam_name
        expose :agami_kam_contact
        expose :agami_kam_email
        expose :delivery_responsibility
        expose :product_lead_time
        expose :return_days
        expose :email
        expose :address_line
        expose :created_by

        def created_by
          {
            id: object.created_by_id,
            name: Staff.unscoped.find_by(id: object.created_by_id)&.name,
          }
        end
      end
    end
  end
end
