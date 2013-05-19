require 'bundler'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new(:generators) do |task|
  task.pattern = "spec/generators/**/*_spec.rb"
end

RSpec::Core::RakeTask.new(:rolify) do |task|
  task.pattern = "spec/rolify/**/*_spec.rb"
end

task :default => :spec

desc "Run all specs"
task "spec" do
  Rake::Task['generators'].invoke
  return_code1 = $?.exitstatus
  Rake::Task['rolify'].invoke
  return_code2 = $?.exitstatus
  fail if return_code1 != 0 || return_code2 != 0
end

desc "Run specs for all adapters"
task :spec_all do
  %w[active_record].each do |model_adapter|
    puts "ADAPTER = #{model_adapter}"
    system "ADAPTER=#{model_adapter} rake"
  end
end