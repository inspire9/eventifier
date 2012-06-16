$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
$LOAD_PATH.unshift File.dirname(__FILE__)

require 'fabrication'
require "./spec/test_classes/#{ENV['ORM'] || 'active_record'}_support.rb"

Fabrication.configure do |config|
  config.fabricator_dir = ["spec/fabricators"]
end


Dir["./spec/support/**/*.rb"].each {|f| require f}

require 'rubygems'
require 'rspec'
require 'eventifier'
