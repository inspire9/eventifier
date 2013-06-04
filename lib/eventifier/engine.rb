module Eventifier
  class Engine < Rails::Engine
    engine_name :eventifier

    config.after_initialize do
      ::EventTracking.new
    end

    ActiveSupport.on_load :action_controller do
      include Eventifier::NotificationHelper

      helper_method :notification_message
    end
  end
end
