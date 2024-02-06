module ShopothWarehouse
  module V1
    module Entities
      class BankAccounts < Grape::Entity
        expose :id
        expose :title
        expose :bank_name
        expose :account_name
        expose :branch_name
        expose :account_type
        expose :account_holder

        def account_type
          if object.ownerable_type == 'Supplier'
            'Supplier'
          elsif object.ownerable_type == 'Distributor'
            'Distributor'
          elsif finance_staff?
            'Finance'
          else
            'Warehouse'
          end
        end

        def account_holder
          if object.ownerable_type == 'Supplier'
            object.ownerable.supplier_name
          elsif finance_staff?
            'Finance'
          elsif fc_staff?
            'FC'
          elsif cwh_staff?
            'CWH'
          else
            object.ownerable.name
          end
        end

        def finance_staff?
          @finance_staff ||= object.ownerable.staffs.finance.present?
        end

        def fc_staff?
          object.ownerable.staffs.fulfilment_center.present?
        end

        def cwh_staff?
          object.ownerable.staffs.central_warehouse.present?
        end
      end
    end
  end
end
