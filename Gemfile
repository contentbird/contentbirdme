source 'https://rubygems.org'

ruby '2.1.0'

gem 'rails', '4.0.5'

group :dependency do
  gem 'nokogiri', '=1.5.6' #gem gets too big > 1.5.6
  gem 'posix-spawn', '=0.3.6' #0.3.8 fails to compile c extension on MAC OS X
end

gem 'resque'
gem 'resque-scheduler', require: 'resque_scheduler'

gem 'rack-timeout'
gem 'faraday'
gem 'cb-render', git: 'https://github.com/contentbird/cb-render.git', branch: 'master'
gem 'cb-api',    git: 'https://github.com/contentbird/cb-api.git',    branch: 'master'

group :production do
  gem 'unicorn'
  gem 'dalli'
  #gem 'pg'
  gem 'newrelic_rpm'
  gem 'rails_log_stdout',           git: 'https://github.com/heroku/rails_log_stdout.git', branch: 'master'
  gem 'rails3_serve_static_assets', git: 'https://github.com/heroku/rails3_serve_static_assets.git', branch: 'master'
end

group :assets do
    gem 'sass-rails'
    gem 'uglifier', '>= 1.3.0'
    gem 'coffee-rails'
end

gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 1.0.1'

group :development, :test do
  #gem 'sqlite3'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'factory_girl'
  gem 'shoulda-matchers'

  gem 'guard-rspec', require: false
  gem 'rspec-nc'

  gem 'therubyracer', '=0.11.4'
  gem 'libv8'
end

group :test do
  gem 'webmock'
end