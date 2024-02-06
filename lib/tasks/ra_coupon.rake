namespace :ra_coupon do
  desc 'RA coupon Create'
  task create: :environment do |t, args|
    ra_coupons = Coupon.where(usable_type: 'RetailerAssistant')
    ra_coupons.destroy_all if ra_coupons.present?
    promotions = Promotion.ra_discount.active.where('from_date <= :today AND to_date >= :today', today: Date.today)
    if promotions.present?
      promotions.each do |promotion|
        promotion.value_for('coupons').to_i.times.each do
          RetailerAssistant.active.all.each do |retailer_assistant|
            retailer_assistant.coupons.create(promotion: promotion)
            Rails.logger.info("<<<<<<Ra Coupon Created>>>>>>")
          end
        end
      end
    end
  end
end
