module Eventifier
  class Railtie < Rails::Railtie
    config.after_initialize do
      ::EventTracking.new if defined?(::EventTracking)
    end
  end
end