class ChangeEmailColNullOfRider < ActiveRecord::Migration[6.0]
  def change
    change_column_null(:riders, :email, true)
  end
end
