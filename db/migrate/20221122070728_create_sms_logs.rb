class CreateSmsLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :sms_logs do |t|
      t.integer :sms_type
      t.string :content
      t.json :gateway_response
      t.string :phone, index: true

      t.timestamps
    end
  end
end
