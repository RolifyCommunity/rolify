require 'bundler'
Bundler::GemHelper.install_tasks

task :default => :spec

desc "Run all specs"
task "spec" do
  Rake::Task['generators'].invoke
  return_code1 = $?.exitstatus
  Rake::Task['rolify'].invoke
  return_code2 = $?.exitstatus
  fail if return_code1 != 0 || return_code2 != 0
end

task "generators" do
  system "bundle exec rspec spec/generators"
end

task "rolify" do
  system "bundle exec rspec spec/rolify"
end
