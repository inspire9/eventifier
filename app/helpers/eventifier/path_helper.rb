module Eventifier
  module PathHelper
    def render_partial_view notification, context = nil
      render(partial: partial_path(notification, context), object: notification.event, locals: { notification: notification, event: notification.event, object: notification.event.eventable })
    end

    def partial_path notification, context = nil
      if lookup_context.exists?(notification.event.eventable_type.underscore, [[:eventifier, context].compact.join("/")], true)
        [:eventifier, context, notification.event.eventable_type.underscore].compact.join("/")
      else
        [:eventifier, context, 'notification'].compact.join("/")
      end
    end
  end
end
