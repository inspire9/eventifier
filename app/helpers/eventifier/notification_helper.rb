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

    def event_message event
      if event.verb.to_sym == :update
        if event.change_data.keys.count == 1
          key = "events.#{event.eventable_type.downcase}.#{event.verb}.single"
        else
          key = "events.#{event.eventable_type.downcase}.#{event.verb}.multiple"
        end
      else
        key = "events.#{event.eventable_type.downcase}.#{event.verb}"
      end
      message = I18n.translate key, :default => :"events.default.#{event.verb}", "user.name" => event.user.name, :"event.type" => event.eventable_type

      replace_vars(message, event).html_safe
    end

    # Used to replace {{variables}} in I18n messages
    def replace_vars message, event
      event = load_event_for_template event
      message.scan(/{{[^}]*}}/) do |replaceable|
        method = "event."+replaceable.to_s.gsub(/[{|}]/, '').to_s
        replace_text = eval(method) rescue ""

        case replaceable.to_s
          when "{{object.name}}"
            replace_text = "<strong class='target'>#{replace_text}</strong>"
          when "{{object.title}}"
            replace_text = "<strong class='target'>#{replace_text}</strong>"
          when "{{user.name}}"
            replace_text = "<strong class='user'>#{replace_text}</strong>"
          else
            replace_text = "<strong>#{replace_text}</strong>"
        end

        message = message.gsub(replaceable.to_s, replace_text.to_s.gsub("_", " "))
      end
      message
    end

    # Make is so you can include object in the I18n descriptions and it refers to the eventable object the event is referring to.
    def load_event_for_template event
      def event.object; eventable; end
      def event.object_type; eventable_type; end

      event
    end
  end
end
