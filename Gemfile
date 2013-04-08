#source "https://rubygems.org"
source "http://ruby.taobao.org"

gem 'rack'
gem 'sinatra'

gem 'activerecord', '~> 3.2', :require => 'active_record'
gem 'activesupport'
gem "sinatra-activerecord"
gem 'pg'
gem 'rgeo'
gem 'activerecord-postgis-adapter'
gem 'uuidtools'
gem 'ncommons',:git => 'git://github.com/weidewang/ncommons.git'

gem 'dalli'
gem 'second_level_cache'
gem 'kgio'

group :production do
  gem 'rainbows'
end

group :development do
  gem 'thin'
  gem 'pry'
  gem 'sinatra-contrib'
end

group :test do
  gem 'minitest', "~>2.6.0", :require => "minitest/autorun"
  gem 'rack-test', :require => "rack/test"
  gem 'factory_girl'
  gem 'database_cleaner'
end
