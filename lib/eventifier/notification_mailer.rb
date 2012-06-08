require 'eventifier/notification_helper'

module Eventifier
  class NotificationMailer < ActionMailer::Base
    include Eventifier::NotificationHelper
    layout 'email'

    default :from => "\"Funways\" <noreply@funways.me>"

    def notification_email(notification)
      @notification = notification
      @notification_url = notification_url(notification.event.eventable)
      @notification_message = notification_message(notification.event).gsub("class='target'", "style='color: #ff0c50'").html_safe

      mail :to => notification.user.email,
           :subject => "You have new notifications"

    end
  end
end