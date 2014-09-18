module Eventifier
  module PathHelper
    def render_partial_view notification, context = nil
      render(partial: partial_path(notification, context), object: notification.event, locals: { notification: notification, event: notification.event, object: notification.event.eventable })
    end

    def partial_path notification, context = nil
      eventable_path = notification.event.eventable_type.underscore.gsub('/', '_')
      if lookup_context.exists?(eventable_path, [[:eventifier, context].compact.join("/")], true)
        [:eventifier, context, eventable_path].compact.join("/")
      else
        [:eventifier, context, 'notification'].compact.join("/")
      end
    end
  end
end
