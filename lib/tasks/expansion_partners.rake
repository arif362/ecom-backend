require 'csv'
namespace :expansion_partners do

  task create_district_thana_areas: :environment do |t, args|
    csv = CSV.read(Rails.root.join('tmp/csv/locations.csv'),
                   headers: true, col_sep: ',', header_converters: :symbol)
    csv.each_with_index do |row, i|
      district = District.find_or_create_by!(name: row[:district_name].to_s.strip) do |district|
        district.bn_name = row[:bn_district_name].to_s.strip
        district.warehouse_id = Warehouse.find_by(name: row[:warehouse_name].to_s.strip)&.id
      end

      thana = district.thanas.find_or_create_by!(name: row[:thana_name].to_s.strip) do |thana|
        thana.bn_name = row[:bn_thana_name].to_s.strip
        thana.distributor_id = row[:distributor_id].to_i
      end

      thana.areas.find_or_create_by!(name: row[:area_name].to_s.strip) do |area|
        area.bn_name = row[:bn_area_name].to_s.strip
      end

      p "District #{district.name}, Thana #{thana.name}, Area #{row[:area_name].to_s.strip} creation successful"
    rescue StandardError => error
      p "failed index: #{i}"
      p "location creation failed index:#{i} name: #{row[:name]} #{error.message}"
    end
  end

  task add_distributors: :environment do |t, args|
    csv = CSV.read(Rails.root.join('tmp/csv/distributors.csv'),
                   headers: true, col_sep: ',', header_converters: :symbol)
    csv.each_with_index do |row, i|
      warehouse = Warehouse.find(row[:warehouse_id].to_i)
      warehouse.distributors.find_or_create_by!(name: row[:name].to_s.strip) do |distributor|
        distributor.bn_name = row[:bn_name].to_s.strip
      end
      p "Distributor #{row[:name]} creation successful "

    rescue StandardError => error
      p "failed index: #{i}"
      p "Distributor creation failed index:#{i} name: #{row[:name]} #{error.message}"
    end
  end

  task add_routes: :environment do |t, args|
    csv = CSV.read(Rails.root.join('tmp/csv/routes.csv'),
                   headers: true, col_sep: ',', header_converters: :symbol)
    csv.each_with_index do |row, i|
      distributor = Distributor.find(row[:distributor_id].to_i)
      distributor.routes.find_or_create_by!(title: row[:title].to_s.strip) do |route|
        route.bn_title = row[:bn_title].to_s.strip
        route.sr_point = row[:sr_point].to_s.strip
        route.sr_name = row[:sr_name].to_s.strip
        route.warehouse_id = distributor.warehouse_id
      end
      p "Route #{row[:title]} creation successful "
    rescue StandardError => error
      p "failed index: #{i}"
      p "Sr creation failed index:#{i} name: #{row[:title]} #{error.message}"
    end
  end

  task add_partners: :environment do |t, args|
    csv = CSV.read(Rails.root.join('tmp/csv/partners.csv'),
                   headers: true, col_sep: ',', header_converters: :symbol)
    csv.each_with_index do |row, i|
      route = Route.find_by(title: row[:route_title].to_s.strip)
      partner = route.partners.find_or_create_by!(phone: row[:phone].to_s.strip.to_s,
                                                  partner_code: row[:partner_code].to_s.strip) do |partner|
        partner.name = row[:name].to_s.strip
        partner.territory = row[:territory].to_s.strip
        partner.region = row[:region].to_s.strip
        partner.status = row[:status].to_i
        partner.password = '123456'
        partner.bn_name = row[:bn_name].to_s.strip
        partner.password_confirmation = '123456'
        partner.schedule = row[:schedule].to_i
        partner.tsa_id = row[:tsa_id].to_s.strip
        partner.retailer_code = row[:retailer_code].to_s.strip
        partner.cluster_name = row[:cluster_name].to_s.strip
        partner.sub_channel = row[:sub_channel].to_s.strip
        partner.latitude = row[:latitude].to_d
        partner.longitude = row[:longitude].to_d
        partner.point = row[:point].to_s.strip
        partner.slug = partner_uniq_slug(partner.name)
      end

      p "Partner #{row[:area]} #{i}"

      create_address(partner, row[:area].to_s.strip, row[:address_line].to_s.strip)

      p "Partner #{row[:name]} creation successful for row no #{i}"

    rescue StandardError => error
      p "failed index: #{i}"
      p "Partner creation failed index:#{i} name: #{row[:title]} #{error.message}"
      next
    end
  end

  task update_partner_region: :environment do |t, args|
    csv = CSV.read(Rails.root.join('tmp/csv/partners.csv'),
                   headers: true, col_sep: ',', header_converters: :symbol)
    csv.each_with_index do |row, i|
      route = Route.find_by(title: row[:route_title].to_s.strip)
      partner = route.partners.find_by(phone: row[:phone].to_s.strip.to_s,
                                                  partner_code: row[:partner_code].to_s.strip)

      partner.update_columns(region: row[:region].to_s.strip)
      p "Region of partner #{row[:name]} updated successful for row no #{i}"

    rescue StandardError => error
      p "failed index: #{i}"
      p "Partner creation failed index:#{i} name: #{row[:title]} #{error.message}"
      next
    end
  end

  task update_partner_schedule: :environment do |t, args|
    csv = CSV.read(Rails.root.join('tmp/csv/partners.csv'),
                   headers: true, col_sep: ',', header_converters: :symbol)
    csv.each_with_index do |row, i|
      route = Route.find_by(title: row[:route_title].to_s.strip)
      partner = route.partners.find_by(phone: row[:phone].to_s.strip.to_s,
                                       partner_code: row[:partner_code].to_s.strip)

      partner.update_columns(schedule: row[:schedule].to_i)
      p "schedule of partner #{row[:name]} updated successful for row no #{i}"

    rescue StandardError => error
      p "failed index: #{i}"
      p "Partner creation failed index:#{i} name: #{row[:title]} #{error.message}"
      next
    end
  end

  task update_partner_phone: :environment do |t, args|
    csv = CSV.read(Rails.root.join('tmp/csv/partner_phones.csv'),
                   headers: true, col_sep: ',', header_converters: :symbol)
    csv.each_with_index do |row, i|
      route = Route.find_by(title: row[:route_title].to_s.strip)
      partner = route.partners.find_by(phone: row[:phone].to_s.strip.to_s)

      partner.update_columns(phone: row[:updated_phone].to_s.strip.to_s)
      p "schedule of partner #{row[:phone]} updated successful for row no #{i}"

    rescue StandardError => error
      p "failed index: #{i}"
      p "Partner creation failed index:#{i} name: #{row[:phone]} #{error.message}"
      next
    end
  end

  def partner_uniq_slug(title)
    slug = title.to_s.parameterize
    index = 0

    while Partner.find_by(slug: slug)
      index += 1
      slug = "#{title.to_s.parameterize}-#{index}"
    end

    slug
  end

  def create_address(partner, area_name, address_line)
    area = Area.find_by(name: area_name)
    return unless area.present?

    partner.create_address(
      {
        area_id: area.id,
        thana_id: area.thana_id,
        district_id: area.thana.district_id,
        name: partner.name,
        address_line: address_line,
        phone: partner.phone,
        default_address: true,
      },
      )
  end

end
