require 'eventifier/notification_helper'

module Eventifier
  class NotificationMailer < ActionMailer::Base
    include Eventifier::NotificationHelper
    layout 'email'

    def notification_email(notification)
      @notification = notification
      @notification_url = if Eventifier::EventTracking.url_mappings[notification.event.eventable_type.underscore.to_sym]
          main_app.url_for Eventifier::EventTracking.url_mappings[notification.event.eventable_type.underscore.to_sym].call(notification.event.eventable)
        else
          main_app.url_for notification.event.eventable
        end
      @notification_message = notification_message(notification.event)

      mail :to => notification.user.email,
           :subject => "You have new notifications"

    end
  end
end