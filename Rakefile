require 'bundler'
Bundler::GemHelper.install_tasks

task :default => :spec

desc "Run all specs"
task "spec" do
  exec "bundle exec rspec spec/generators && bundle exec rspec spec/rolify"
end
