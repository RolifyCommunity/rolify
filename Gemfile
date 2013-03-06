source "http://rubygems.org"

case ENV["ADAPTER"]
when nil, "active_record"
  if defined?(RUBY_ENGINE) && RUBY_ENGINE == "jruby"
    gem "activerecord-jdbcsqlite3-adapter"
  else
    gem "sqlite3"
  end
  gem "activerecord", ">= 3.1.0", :require => "active_record"
when "mongoid"
  gem "bson_ext" if RUBY_VERSION < "2.0.0"
  gem "mongoid", ">= 3.1"
else
  raise "Unknown model adapter: #{ENV["ADAPTER"]}"
end

gemspec
