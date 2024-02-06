# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, 'log/cron_log.log'
#

# require 'tzinfo'
#
# def local(time)
#   TZInfo::Timezone.get("Asia/Dhaka").local_to_utc(Time.parse(time))
# end

every :day, at: ['12:00 AM'] do
  command "cd /var/app/current/ && RAILS_ENV=pre_prod /opt/elasticbeanstalk/.rbenv/shims/bundle exec /opt/elasticbeanstalk/.rbenv/shims/rake route:app_notification"
  command "cd /var/app/current/ && RAILS_ENV=pre_prod /opt/elasticbeanstalk/.rbenv/shims/bundle exec /opt/elasticbeanstalk/.rbenv/shims/rake rider:app_notification"
end

every :day, at: ['12:05 AM'] do
  command "cd /var/app/current/ && RAILS_ENV=pre_prod /opt/elasticbeanstalk/.rbenv/shims/bundle exec /opt/elasticbeanstalk/.rbenv/shims/rake customer_order:expire_extension"
end

every :day, at: ['2:00 AM'] do
  command "cd /var/app/current/ && RAILS_ENV=pre_prod /opt/elasticbeanstalk/.rbenv/shims/bundle exec /opt/elasticbeanstalk/.rbenv/shims/rake recommendations:recalculate"
end

# 6:10 PM is utc time which is actually 12:10am bd time
# in the staging the cron tab are configure to use that is why this was done

every :day, at: ['6:10 PM'] do
  command "cd /var/app/current/ && RAILS_ENV=pre_prod /opt/elasticbeanstalk/.rbenv/shims/bundle exec /opt/elasticbeanstalk/.rbenv/shims/rake ra_coupon:create"
end

every :day, at: ['8 PM'] do
  command "cd /var/app/current/ && RAILS_ENV=pre_prod /opt/elasticbeanstalk/.rbenv/shims/bundle exec /opt/elasticbeanstalk/.rbenv/shims/rake cancel_orders:online_payments_pending"
end

every '10 18 8 * *' do
  command "cd /var/app/current/ && RAILS_ENV=pre_prod /opt/elasticbeanstalk/.rbenv/shims/bundle exec /opt/elasticbeanstalk/.rbenv/shims/rake month_wise_payment_history:create"
end

# Learn more: http://github.com/javan/whenever
#

every :day, at: ['7:00 AM'] do
  command "cd /var/app/current/ && RAILS_ENV=pre_prod /opt/elasticbeanstalk/.rbenv/shims/bundle exec /opt/elasticbeanstalk/.rbenv/shims/rake sitemap:refresh:no_ping"
end

# every :day, at: ['7:00 AM'] do
#   command "cd /var/app/current/ && RAILS_ENV=production /opt/elasticbeanstalk/.rbenv/shims/bundle exec /opt/elasticbeanstalk/.rbenv/shims/rake sitemap:refresh"
# end
