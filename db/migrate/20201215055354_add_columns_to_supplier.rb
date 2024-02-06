class AddColumnsToSupplier < ActiveRecord::Migration[6.0]
  def change
    add_column :suppliers, :mou_document_number, :string
    add_column :suppliers, :supplier_name, :string
    add_column :suppliers, :bn_supplier_name, :string
    add_column :suppliers, :supplier_representative, :string
    add_column :suppliers, :bn_supplier_representative, :string
    add_column :suppliers, :representative_designation, :string
    add_column :suppliers, :bn_representative_designation, :string
    add_column :suppliers, :representative_contact, :string
    add_column :suppliers, :bn_representative_contact, :string
    add_column :suppliers, :supplier_email, :string
    add_column :suppliers, :tin, :string
    add_column :suppliers, :bin, :string
    add_column :suppliers, :contract_start_date, :date
    add_column :suppliers, :contract_end_date, :date
    add_column :suppliers, :bank_name, :string
    add_column :suppliers, :bn_bank_name, :string
    add_column :suppliers, :account_number, :string
    add_column :suppliers, :swift_code, :string
    add_column :suppliers, :bn_swift_code, :string
    add_column :suppliers, :central_warehouse_address, :string
    add_column :suppliers, :bn_central_warehouse_address, :string
    add_column :suppliers, :local_warehouse_address, :string
    add_column :suppliers, :bn_local_warehouse_address, :string
    add_column :suppliers, :pre_payment, :boolean
    add_column :suppliers, :product_quality_rating, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :suppliers, :deliver_time_rating, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :suppliers, :service_quality_rating, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :suppliers, :professionalism_rating, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :suppliers, :post_payment, :boolean
    add_column :suppliers, :credit_payment, :boolean
    add_column :suppliers, :credit_days, :integer
    add_column :suppliers, :credit_limit,:decimal
    add_column :suppliers, :agami_kam_name, :string
    add_column :suppliers, :bn_agami_kam_name, :string
    add_column :suppliers, :agami_kam_contact, :string
    add_column :suppliers, :bn_agami_kam_contact, :string
    add_column :suppliers, :agami_kam_email,:string
    add_column :suppliers, :delivery_responsibility, :string
    add_column :suppliers, :bn_delivery_responsibility, :string
    add_column :suppliers, :product_lead_time, :integer
    add_column :suppliers, :return_days, :integer
    add_column :suppliers, :pickup_locations, :string, array: true, default: []
    add_column :suppliers, :bn_pickup_locations, :string, array: true, default: []
  end
end
