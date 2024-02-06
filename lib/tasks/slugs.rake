namespace :slugs do
  desc 'This task will update slug in friendly_id_slugs table'
  task add_history: :environment do |t, args|
    %w(Product Category Brand Partner Article HelpTopic).each do |obj_class|
      process_for_slug(obj_class.constantize)
    end

  end

  desc 'Task for slug adding in product_type'
  task update_product_type: :environment do |t, args|
    ProductType.all.each do |product_type|
      product_type.update!(slug: product_type_uniq_slug(product_type.title), bn_title: "#{product_type.title}-#{product_type.id}-bn" )
      puts "slug history updated for product type -- #{product_type.id}"
    end
  rescue StandardError => error
    puts "--- Error due to: #{error}"
  end

  def process_for_slug(obj_model)
    obj_model.all.find_in_batches do |objects|
      update_objects(objects)
    end
  end

  def update_objects(objects)
    objects.each do |object|
      next unless object.slug.present?

      FriendlyIdSlug.find_or_create_by(slug: object.slug, sluggable: object)

      puts "slug history updated for #{object.class} -- #{object.id}"
    rescue => ex
      puts "--- Error for #{object.class} #{object.id} due to: #{ex}"
    end
  end

  def product_type_uniq_slug(title)
    slug = title.to_s.parameterize
    index = 0

    while ProductType.find_by(slug: slug)
      index += 1
      slug = "#{title.to_s.parameterize}-#{index}"
    end

    slug
  end

end
