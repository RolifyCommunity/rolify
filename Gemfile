source "https://rubygems.org"

group :test do
  case ENV["ADAPTER"]
  when nil, "active_record"
    gem "activerecord-jdbcsqlite3-adapter", ">= 1.3.0.rc", :platform => "jruby"
    gem "sqlite3", :platform => "ruby"
    gem "activerecord", ">= 3.2.0", :require => "active_record"
  when "mongoid"
    gem "mongoid", ">= 3.1"
    gem "bson_ext", :platform => "ruby"
  else
    raise "Unknown model adapter: #{ENV["ADAPTER"]}"
  end

  gem 'coveralls', :require => false
  gem 'its'
  gem 'byebug'
  gem 'pry-byebug'
  gem 'codeclimate-test-reporter', :require => nil
end

gemspec
