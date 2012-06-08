module Eventifier
  module HelperMethods
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