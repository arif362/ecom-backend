class RemoveColumnsFromSupplier < ActiveRecord::Migration[6.0]
  def up
    remove_columns :suppliers, :company, :email
    remove_columns :suppliers, :bn_company
    remove_columns :suppliers, :bn_phone
    remove_columns :suppliers, :contact_person
    remove_columns :suppliers, :contact_person_email
    remove_columns :suppliers, :contact_person_phone
    remove_columns :suppliers, :bn_supplier_name
    remove_columns :suppliers, :bn_supplier_representative
    remove_columns :suppliers, :bn_representative_designation
    remove_columns :suppliers, :bn_representative_contact
    remove_columns :suppliers, :supplier_email
    remove_columns :suppliers, :bn_bank_name
    remove_columns :suppliers, :bn_swift_code
    remove_columns :suppliers, :bn_central_warehouse_address
    remove_columns :suppliers, :bn_local_warehouse_address
    remove_columns :suppliers, :bn_agami_kam_name
    remove_columns :suppliers, :bn_agami_kam_contact
    remove_columns :suppliers, :bn_delivery_responsibility
    remove_columns :suppliers, :pickup_locations
    remove_columns :suppliers, :bn_pickup_locations
  end

  def down
    add_column :suppliers, :company, :string
    add_column :suppliers, :bn_company, :string
    add_column :suppliers, :bn_phone, :string
    add_column :suppliers, :contact_person, :string
    add_column :suppliers, :contact_person_email, :string
    add_column :suppliers, :contact_person_phone, :string
    add_column :suppliers, :bn_supplier_name, :string
    add_column :suppliers, :bn_supplier_representative, :string
    add_column :suppliers, :bn_representative_designation, :string
    add_column :suppliers, :bn_representative_contact, :string
    add_column :suppliers, :supplier_email, :string
    add_column :suppliers, :bn_bank_name, :string
    add_column :suppliers, :bn_swift_code, :string
    add_column :suppliers, :bn_central_warehouse_address, :string
    add_column :suppliers, :bn_local_warehouse_address, :string
    add_column :suppliers, :bn_agami_kam_name, :string
    add_column :suppliers, :bn_agami_kam_contact, :string
    add_column :suppliers, :bn_delivery_responsibility, :string
    add_column :suppliers, :pickup_locations, :string
    add_column :suppliers, :bn_pickup_locations, :string
  end
end
