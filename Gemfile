source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails',                      '6.1.3.2'
gem 'pg', '~> 1.2', '>= 1.2.3'
gem 'tzinfo-data'
gem 'image_processing',           '1.9.3'
gem 'mini_magick',                '4.11.0'
gem 'active_storage_validations', '0.8.2'
gem 'pagedown-rails', '~> 1.1.4'
gem "nokogiri", ">= 1.4.2"
gem "kramdown", "2.3.0"
gem 'bcrypt', '3.1.13'
gem 'faker', '2.1.2'
gem 'will_paginate-bootstrap4'
gem 'bootstrap-will_paginate', '1.0.0'
gem 'bootstrap', '~> 4.5.0'
gem 'jquery-rails'
gem 'turbo-rails'
gem 'puma',       '4.3.5'
gem 'sass-rails', '6.0.0'
gem 'webpacker',  '4.2.2'
gem 'jbuilder',   '2.10.0'
gem 'bootsnap',   '1.4.6', require: false
gem "aws-sdk-s3", require: false

group :development, :test do
  gem 'sqlite3', '1.4.2'
  gem 'byebug',  '11.1.3', platforms: [:mri, :mingw, :x64_mingw]
  gem 'figaro'
end

group :development do
  gem 'web-console',           '4.0.2'
  gem 'listen',                '3.2.1'
  gem 'spring',                '2.1.0'
  gem 'spring-watcher-listen', '2.0.1'
end

group :test do
  gem 'capybara',                 '3.32.2'
  gem 'selenium-webdriver',       '3.142.7'
  gem 'webdrivers',               '4.3.0'
  gem 'rails-controller-testing', '1.0.4'
  gem 'minitest',                 '5.11.3'
  gem 'minitest-reporters',       '1.3.8'
  gem 'guard',                    '2.16.2'
  gem 'guard-minitest',           '2.4.6'
end

#group :production do
#  gem 'aws-sdk-s3', '1.46.0', require: false
#end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# Uncomment the following line if you're running Rails
# on a native Windows system:
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]