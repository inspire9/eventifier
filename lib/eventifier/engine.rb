module Eventifier
  class Engine < Rails::Engine
    config.after_initialize do
      ::EventTracking.new
    end
  end
end
