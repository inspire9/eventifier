$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
$LOAD_PATH.unshift File.dirname(__FILE__)

Dir["./spec/support/**/*.rb"].each {|f| require f}

require 'rubygems'
require 'rspec'
require 'eventifier'