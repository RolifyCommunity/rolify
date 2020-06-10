appraise 'mongoid-5' do
  gem "mongoid", "~> 5"
  gem "bson_ext", "1.5.1"
  gem 'bigdecimal', '1.4.2'
end

appraise 'mongoid-6' do
  gem "mongoid", "~> 6"
  gem "bson_ext", "1.5.1"
end

appraise 'mongoid-7' do
  gem "mongoid", "~> 7"
  gem "bson_ext", "1.5.1"
  gem "railties", "5.2.4.1"
end

appraise 'activerecord-4' do
  gem "sqlite3", "~> 1.3.6"
  gem "activerecord", "~> 4.2.11", :require => "active_record"
  gem 'bigdecimal', '1.4.2'
end

appraise 'activerecord-5' do
  gem "sqlite3", "~> 1.3.6"
  gem "activerecord", "~> 5.2.4", :require => "active_record"

  # Ammeter dependencies:
  gem "actionpack", "~> 5.2.4"
  gem "activemodel", "~> 5.2.4"
  gem "railties", "~> 5.2.4"

  gem 'rspec-rails'       , github: 'rspec/rspec-rails'
  gem 'rspec-core'        , github: 'rspec/rspec-core'
  gem 'rspec-expectations', github: 'rspec/rspec-expectations'
  gem 'rspec-mocks'       , github: 'rspec/rspec-mocks'
  gem 'rspec-support'     , github: 'rspec/rspec-support'
end

appraise 'activerecord-6' do
  gem "sqlite3", "~> 1.4", :platform => "ruby"
  gem "activerecord", ">= 6.0.0", :require => "active_record"

  # Ammeter dependencies:
  gem "actionpack", ">= 6.0.0"
  gem "activemodel", ">= 6.0.0"
  gem "railties", ">= 6.0.0"

  gem 'rspec-rails'       , github: 'rspec/rspec-rails'
  gem 'rspec-core'        , github: 'rspec/rspec-core'
  gem 'rspec-expectations', github: 'rspec/rspec-expectations'
  gem 'rspec-mocks'       , github: 'rspec/rspec-mocks'
  gem 'rspec-support'     , github: 'rspec/rspec-support'
end
