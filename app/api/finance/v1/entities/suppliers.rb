module Finance
  module V1
    module Entities
      class Suppliers < Grape::Entity
        expose :id
        expose :supplier_name
        expose :phone
        expose :mou_document_number
        expose :supplier_representative
        expose :representative_designation
        expose :representative_contact
        expose :tin
        expose :bin
        expose :contract_start_date
        expose :contract_end_date
        expose :agami_kam_contact
        expose :agami_kam_email
        expose :email
      end
    end
  end
end
