require "bundler/gem_tasks"

require 'rake'
require 'rspec/core/rake_task'
require 'rdoc/task'


RSpec::Core::RakeTask.new

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.rcov = true
  spec.rcov_opts = ['--exclude', 'spec', '--exclude', '.rvm']
end