class Eventifier::EventSubscriber
  def self.subscribe_to_all klass, names
    names.each do |method_name|
      new.subscribe_to_method klass, method_name
    end
  end

  def subscribe_to_method klass, method_name
    name = "#{method_name}.#{klass.name.tableize}.event.eventifier"

    return if ActiveSupport::Notifications.notifier.listening?(name)

    ActiveSupport::Notifications.subscribe name do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)
      event_user = if event.payload[:user]
        Eventifier::Relationship.new(event.payload[:object], event.payload[:user]).users.first
      else
        event.payload[:object].user
      end

      eventifier_event = Eventifier::Event.create(
        user:         event_user,
        eventable:    event.payload[:object],
        verb:         event.payload[:event],
        change_data:  change_data(event.payload[:object], event.payload[:options])
      )

      ActiveSupport::Notifications.instrument("#{method_name}.#{klass.name.tableize}.notification.eventifier", event: :create, event: eventifier_event, object: event.payload[:object])
    end
  end

  private
  def change_data object, options
    change_data = object.changes.stringify_keys

    change_data = change_data.reject { |attribute, value| options[:except].include?(attribute) } if options[:except]
    change_data = change_data.select { |attribute, value| options[:only].include?(attribute) } if options[:only]

    change_data.symbolize_keys
  end
end