# rubocop:disable Style/Documentation
class CreateSuppliers < ActiveRecord::Migration[6.0]
  # rubocop:disable Metrics/MethodLength
  def change
    create_table :suppliers do |t|
      t.string :company, null: false
      t.string :bn_company
      t.string :name, null: false
      t.string :bn_name
      t.string :phone
      t.string :bn_phone
      t.string :mobile
      t.string :bn_mobile
      t.string :reliability
      t.string :status

      t.timestamps
    end
  end
end
