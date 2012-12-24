module Eventifier
  class Railtie < Rails::Railtie
    config.after_initialize do
      ::EventTracking.new
    end
  end
end