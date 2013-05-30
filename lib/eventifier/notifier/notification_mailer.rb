require 'eventifier/notifier/notification_helper'

module Eventifier
  class NotificationMailer < ActionMailer::Base
    include Eventifier::NotificationHelper
    layout 'email'

    def notification_email(notification)
      @notification = notification
      @notification_url = main_app.url_for notification.url
      @notification_message = notification_message(notification.event)

      mail :to => notification.user.email,
           :subject => "You have new notifications"

    end
  end
end