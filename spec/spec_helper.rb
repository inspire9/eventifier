require 'bundler'

Bundler.setup :default, :development

require 'fabrication'
require 'combustion'
require 'active_record'
require 'action_view'
require 'haml'
require 'eventifier'

Fabrication.configure do |config|
  config.fabricator_path = ["spec/fabricators"]
  config.path_prefix     = '.'
end

Combustion.initialize! :action_controller, :action_view, :active_record,
  :action_mailer

require 'rspec/rails'

Dir["./spec/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
