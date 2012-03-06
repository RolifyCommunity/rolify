require 'bundler'
Bundler::GemHelper.install_tasks

task :default => :spec

desc "Run all specs"
task "spec" do
  sh "bundle exec rspec spec"
  sh "export ADAPTER=mongoid && bundle exec rspec spec && unset ADAPTER"
end
