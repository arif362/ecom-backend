source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.3', '>= 6.0.3.4'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 5.6.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use Active Storage variant
gem 'image_processing', '~> 1.2'
# File type, size validations for active storage

gem 'active_storage_validations'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# API serializer
gem 'jbuilder', '~> 2.10', '>= 2.10.1'

# pagination
gem 'kaminari', '~> 1.2', '>= 1.2.1'

# Framework for rapid API development
gem 'grape', '~> 1.5'
gem 'grape-entity'
gem 'grape-kaminari'
gem 'grape_on_rails_routes'

# For authentication and authorization
gem 'devise', '~> 4.7.3'
gem 'devise-jwt', '~> 0.8.0'

# For cross-origin requests
gem 'rack-cors', '~> 1.1.1'

# Shim to load environment variables from .env into ENV
gem 'dotenv-rails'
# For encapsulating business logic
gem 'interactor'

# For auditing changes
gem 'audited', '~> 4.9'

# whenever gem
gem 'whenever', require: false

# fcm gem
gem 'fcm', '~> 1.0', '>= 1.0.2'

# For rich logging
# gem 'rails_semantic_logger'

# aws bucket image upload
gem 'aws-sdk-s3', require: false

# convert to words
gem 'humanize'
# converting number to bangla
gem 'to_bn'

# Create pretty URLs and work with human-friendly strings
# gem 'friendly_id', '~> 5.4.0'

# For product recommendations
gem 'predictor'

# Bangladeshi phone number check and fetch
gem 'phone_number_checker', '~> 1.0.0'

# for latitude and longitude calculations
gem 'geocoder'

# elasticsearch
gem 'chewy'

# searching
gem 'pg_search'

#sitemap
gem 'sitemap_generator'


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i(mri mingw x64_mingw)
  gem 'capistrano', '~> 3.11', require: false
  # gem 'capistrano3-puma', '~>4.0.0', require: false
  gem 'capistrano-rails', '~> 1.4', require: false
  gem 'capistrano-rbenv', '~> 2.1', '>= 2.1.4', require: false
  gem 'pry', '~> 0.13.1'
  gem 'rspec', '~> 3.10'
  gem 'bullet'
end

group :development do
  gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Preview email in the default browser instead of sending it
  gem 'letter_opener'
  gem 'rubocop', require: false
end

# Use Active Model has_secure_password
gem 'bcrypt'
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i(mingw mswin x64_mingw jruby)
gem 'nio4r','2.5.8'
gem 'figaro'
gem 'fog-aws'