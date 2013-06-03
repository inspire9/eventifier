module Eventifier
  module NotificationHelper
    # A helper for outputting a notification message.
    #
    # Uses I18n messages from config/locales/events.en.yml to generate these messages, or defaults to a standard.
    #
    # Example:
    #
    # %ul#recent_notifications
    #   - current_user.notifications.each do |notification|
    #     %li= notification_message notification.event

    def notification_message event
      default = "notifications.default.#{event.verb}".to_sym
      if event.verb.to_sym == :update
        if event.change_data.keys.count == 1
          key = "notifications.#{event.eventable_type.downcase}.#{event.verb}.attributes.#{event.change_data.keys.first}"
          default = ["notifications.#{event.eventable_type.downcase}.#{event.verb}.single".to_sym, default]
        else
          key = "notifications.#{event.eventable_type.downcase}.#{event.verb}.multiple"
        end
      else
        key = "notifications.#{event.eventable_type.downcase}.#{event.verb}"
      end
      message = I18n.translate key, :default => default, "user.name" => event.user.name, :"event.type" => event.eventable_type

      replace_vars(message, event).html_safe
    end
  end
end
