$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
$LOAD_PATH.unshift File.dirname(__FILE__)

require 'fabrication'
orm = ENV['ORM'] || 'active_record'
require "./spec/test_classes/#{orm}_support.rb"

Fabrication.configure do |config|
  config.fabricator_dir = ["spec/fabricators"]
end


Dir["./spec/support/**/*.rb"].each { |f| require f }

require 'rubygems'
require 'rspec'
require 'eventifier'

require "./app/mailers/eventifier/mailer.rb"
require "./app/helpers/notification_helper.rb"