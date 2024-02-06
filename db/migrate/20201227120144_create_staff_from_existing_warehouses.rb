class CreateStaffFromExistingWarehouses < ActiveRecord::Migration[6.0]
  def up
    return unless Rails.env.staging?

    role_name = StaffRole::ROLE_NAMES[:distribution_house_manager]
    staff_role = StaffRole.find_by(name: role_name)
    return unless staff_role

    Warehouse.find_each do |warehouse|
      Staff.create(
        first_name: warehouse.name,
        last_name: 'DH Main Admin',
        email: warehouse.email,
        password: warehouse.encrypted_password,
        password_confirmation: warehouse.encrypted_password,
        warehouse: warehouse,
        staff_role: staff_role,
      )

      warehouse.update(
        password: warehouse.encrypted_password,
        password_confirmation: warehouse.encrypted_password,
      )
    end
  end

  def down; end
end
