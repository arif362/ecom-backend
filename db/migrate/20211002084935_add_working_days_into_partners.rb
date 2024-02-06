class AddWorkingDaysIntoPartners < ActiveRecord::Migration[6.0]
  def change
    # Field type should be text to store array of hashes
    add_column :partners, :work_days, :text, default: ''
  end
end
