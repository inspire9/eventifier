module Eventifier
  class NotificationsController < Eventifier::ApplicationController
    def index
      @notifications = current_user.notifications.limit(5)
    end
  end
end