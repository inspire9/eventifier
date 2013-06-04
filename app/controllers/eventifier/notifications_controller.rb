module Eventifier
  class NotificationsController < Eventifier::ApplicationController
    include Eventifier::NotificationHelper
    include Eventifier::PathHelper
    helper_method :notification_message, :event_message, :partial_view

    def index
      @notifications = current_user.notifications.limit(5)
    end
  end
end