source 'https://rubygems.org'

gem 'passenger', '~> 6', require: 'phusion_passenger/rack_handler'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7'
gem 'rdoc', '~> 6'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use mysql2 as the database for Active Record
gem 'mysql2'

# Use SCSS for stylesheets
gem 'sassc-rails'

# Use jsbuilding-rails for JavaScript
gem 'sprockets', '~> 4'
gem 'jsbundling-rails'

# User
gem 'devise'
gem 'omniauth'
gem 'omniauth-facebook'

# Use DB session
gem 'activerecord-session_store'

# Use Redcarpet to render Markdown
gem 'redcarpet'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'

# Pagination
gem 'kaminari'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'json'
gem 'jbuilder'

# Nested form: https://github.com/ryanb/nested_form
gem 'nested_form'

# Upload
# carrierwave, upload handler: https://github.com/carrierwaveuploader/carrierwave
gem 'carrierwave'
gem 'mini_magick'
# compression
gem 'zstd-ruby'
gem 'rubyzip', require: 'zip'

# Mathjax, can render latex equation: https://github.com/pmq20/mathjax-rails
gem 'mathjax-rails-3'

# Tagging feature: https://github.com/mbleigh/acts-as-taggable-on
gem 'acts-as-taggable-on'

# Active Admin, db admin tool: https://github.com/gregbell/active_admin
gem 'activeadmin'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'mechanize'

# friendly id for SEO
gem 'friendly_id'

# annotate (showing model info in model.rb)
gem 'annotate'

# Timezone data
gem 'tzinfo-data'

# Ordered list management: https://github.com/swanandp/acts_as_list
gem 'acts_as_list'

# Activerecord-import for bulk insert
gem 'activerecord-import'

# Fix warning: https://stackoverflow.com/questions/67773514/getting-warning-already-initialized-constant-on-assets-precompile-at-the-time
gem 'net-http'

# Redis for Action Cable
gem 'redis', '~> 4'

# Sentry for monitoring
gem 'sentry-ruby'
gem 'sentry-rails'

group :development do
  # Bullet for debugging
  gem 'bullet', group: 'development'
  gem 'listen', group: 'development'

  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'puma'
end
