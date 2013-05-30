class Eventifier::EventSubscriber
  def self.subscribe_to_all klass, names
    names.each do |method_name|
      new.subscribe_to_method "#{method_name}.#{klass.name.tableize}.eventifier"
    end
  end

  def subscribe_to_method name
    return if ActiveSupport::Notifications.notifier.listening?(name)

    ActiveSupport::Notifications.subscribe name do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)

      Eventifier::Event.create(
        user:         event.payload[:user] || event.payload[:object].user,
        eventable:    event.payload[:object],
        verb:         event.payload[:event],
        change_data:  change_data(event.payload[:object], event.payload[:options])
      )
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