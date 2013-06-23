module Eventifier
  class Engine < Rails::Engine
    engine_name :eventifier

    config.after_initialize do
      ::EventTracking.new
    end
  end
end
