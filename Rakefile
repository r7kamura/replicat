require "bundler/gem_tasks"
require "rspec/core/rake_task"
require File.expand_path('spec/dummy/config/application', File.dirname(__FILE__))

Dummy::Application.load_tasks
RSpec::Core::RakeTask.new('spec' => 'db:create')
task :default => :spec
