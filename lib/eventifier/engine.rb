module Eventifier
  class Engine < Rails::Engine
    config.after_initialize do
      ::EventTracking.new
    end

    ActiveSupport.on_load :action_controller do
      include Eventifier::NotificationHelper

      helper_method :notification_message, :notification_url
    end
  end
end
