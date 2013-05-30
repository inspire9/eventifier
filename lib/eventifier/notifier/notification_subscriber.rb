class Eventifier::NotificationSubscriber
  def self.subscribe_to_method klass, method_name
    key = "#{method_name}.#{klass.name.tableize}"
    name = "#{key}.notification.eventifier"

    return if ActiveSupport::Notifications.notifier.listening?(name)

    ActiveSupport::Notifications.subscribe name do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)
      eventifier_event = event.payload[:event]

      Eventifier::NotificationMapping.users_for(eventifier_event, key).each do |user|
        next if user == eventifier_event.user

        Eventifier::Notification.create(
          event:  eventifier_event,
          user:   user
        )
      end
    end
  end
end