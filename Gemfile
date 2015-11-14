source "https://rubygems.org"

group :test do
  case ENV["ADAPTER"]
  when nil, "active_record"
    gem "activerecord-jdbcsqlite3-adapter", ">= 1.3.0.rc", :platform => "jruby"
    gem "sqlite3", :platform => "ruby"
    gem "activerecord", ">= 3.2.0", :require => "active_record"
  when "mongoid"
    case ENV["MONGOID_VERSION"]
    when nil, '5'
      gem "mongoid", "~> 5"
    when '4'
      gem "mongoid", "~> 4"
    when '3'
      gem "mongoid", "~> 3"
    end
    gem "bson_ext", :platform => "ruby"
  else
    raise "Unknown model adapter: #{ENV["ADAPTER"]}"
  end

  gem 'coveralls', :require => false
  gem 'its'
  gem 'byebug'
  gem 'pry-byebug'
  gem 'test-unit' # Implicitly loaded by ammeter
  gem 'database_cleaner'
  gem 'codeclimate-test-reporter', :require => nil
end

gemspec
