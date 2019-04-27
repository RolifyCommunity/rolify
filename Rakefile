# frozen_string_literal: true

require 'bundler'
require 'rspec/core/rake_task'
require 'coveralls/rake/task'
require 'appraisal'

Bundler::GemHelper.install_tasks

Coveralls::RakeTask.new

RSpec::Core::RakeTask.new(:generators) do |task|
  task.pattern = 'spec/generators/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:rolify) do |task|
  task.pattern = 'spec/rolify/**/*_spec.rb'
end

if !ENV['APPRAISAL_INITIALIZED'] && !ENV['TRAVIS']
  task default: :appraisal
else
  task default: %i[spec coveralls:push]
end

desc 'Run all specs'
task 'spec' do
  Rake::Task['generators'].invoke
  return_code1 = $CHILD_STATUS.exitstatus
  Rake::Task['rolify'].invoke
  return_code2 = $CHILD_STATUS.exitstatus
  raise if return_code1 != 0 || return_code2 != 0
end

desc 'Run specs for all adapters'
task :spec_all do
  %w[active_record mongoid].each do |model_adapter|
    puts "ADAPTER = #{model_adapter}"
    system "ADAPTER=#{model_adapter} rake"
  end
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  nil
end
