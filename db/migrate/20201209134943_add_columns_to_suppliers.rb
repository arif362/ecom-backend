class AddColumnsToSuppliers < ActiveRecord::Migration[6.0]
  def up
    remove_column :suppliers, :name
    remove_column :suppliers, :bn_name
    remove_column :suppliers, :mobile
    remove_column :suppliers, :bn_mobile
    remove_column :suppliers, :reliability
    add_column :suppliers, :email, :string
    add_column :suppliers, :delivery_type, :string
    add_column :suppliers, :contact_person, :string
    add_column :suppliers, :contact_person_email, :string
    add_column :suppliers, :contact_person_phone, :string
    add_column :suppliers, :is_deleted, :boolean, default: false
    change_column :suppliers, :status, 'integer USING CAST(status AS integer)'
    add_index :suppliers, :company
  end

  def down
    add_column :suppliers, :name, :string
    add_column :suppliers, :bn_name, :string
    add_column :suppliers, :mobile, :string
    add_column :suppliers, :bn_mobile, :string
    add_column :suppliers, :reliability, :string
    remove_column :suppliers, :email
    remove_column :suppliers, :delivery_type
    remove_column :suppliers, :contact_person
    remove_column :suppliers, :contact_person_email
    remove_column :suppliers, :contact_person_phone
    remove_column :suppliers, :is_deleted
    change_column :suppliers, :status, :string
    remove_index :suppliers, :company
  end
end
