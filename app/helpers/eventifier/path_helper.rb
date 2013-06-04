module Eventifier
  module PathHelper
    def partial_view notification, context = nil
      if lookup_context.exists?(notification.event.eventable_type.tableize, [:eventifier, context].compact, true)
        [:eventifier, context, notification.event.eventable_type.tableize].compact.join("/")
      else
        [:eventifier, context, 'notification'].compact.join("/")
      end
    end
  end
end