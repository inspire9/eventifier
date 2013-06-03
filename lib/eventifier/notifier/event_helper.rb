module Eventifier
  module EventHelper

    # A helper for outputting an event message.
    #
    # Uses I18n messages from config/locales/events.en.yml to generate these messages, or defaults to a standard.
    #
    # Example:
    #
    # %ul#events
    #   - post.events.each do |event|
    #     %li= event_message event

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

      message.html_safe
    end
  end
end
