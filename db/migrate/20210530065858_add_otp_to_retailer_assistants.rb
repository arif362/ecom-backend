class AddOtpToRetailerAssistants < ActiveRecord::Migration[6.0]
  def change
    add_column :retailer_assistants, :otp, :string
  end
end
