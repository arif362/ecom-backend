class AddConfigurationIsDelatedPrimaryToVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :variants, :configuration, :string
    add_column :variants, :is_deleted, :boolean, default: false
    add_column :variants, :primary, :boolean, default: false
  end
end
