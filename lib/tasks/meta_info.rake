require 'csv'
namespace :meta_info do
  desc 'This task creates insert meta info'
  task upload: :environment do |t, args|
    csv = CSV.read(Rails.root.join('tmp/csv/meta_info.csv'),
                   headers: true, col_sep: ',', header_converters: :symbol)
    fail_rows = []
    fail_rows << ["metable_type", "metable_id", "meta_title", "bn_meta_title", "meta_description", "bn_meta_description", "failed cause"]
    csv.each_with_index do |row, i|
      metaable_class = row[:metable_type].to_s.strip.safe_constantize
      unless metaable_class.present?
        row << "Model not found"
        fail_rows << row
        next
      end

      metaable_object = metaable_class.unscoped.find_by(id: row[:metable_id].to_i)
      if metaable_object.blank?
        row << "Object not found"
        fail_rows << row
        next
      end

      if metaable_object.meta_datum.present?
        row << "Meta data already exist"
        fail_rows << row
        next
      end

      metaable_object.create_meta_datum(meta_title: row[:meta_title].to_s, bn_meta_title: row[:bn_meta_title].to_s,
                                        meta_description: row[:meta_description].to_s, bn_meta_description: row[:bn_meta_description].to_s)

    rescue StandardError => error
      p "failed index: #{i}"
      p "Meta data creation failed index:#{i} name: #{row[:name]} #{error.message}"
    end
    filename = 'tmp/csv/failed_rows.csv'
    File.write(filename, fail_rows.map(&:to_csv).join)
  end
end
