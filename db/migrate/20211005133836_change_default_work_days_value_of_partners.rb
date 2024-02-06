class ChangeDefaultWorkDaysValueOfPartners < ActiveRecord::Migration[6.0]
  def change
    remove_column :partners, :work_days, :text
    add_column :partners, :work_days, :text, default: [{ is_opened: false }, { is_opened: false }, { is_opened: false }, { is_opened: false }, { is_opened: false }, { is_opened: false }, { is_opened: false }].to_yaml
  end
end
