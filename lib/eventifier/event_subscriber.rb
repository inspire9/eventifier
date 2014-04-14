class Eventifier::EventSubscriber
  def self.subscribe_to_all(klass, names)
    names.each do |method_name|
      new(klass, method_name).subscribe_to_method
    end
  end

  def initialize(klass, method_name)
    @klass, @method_name = klass, method_name
  end

  def subscribe_to_method
    return if notifications.notifier.listening?(name)

    notifications.subscribe(name) do |*args|
      event = Eventifier::EventTranslator.new(*args).translate

      notifications.instrument "#{prefix}.notification.eventifier",
        verb: :create, event: event, object: event.eventable
    end
  end

  private

  attr_reader :klass, :method_name

  def name
    "#{prefix}.event.eventifier"
  end

  def notifications
    ActiveSupport::Notifications
  end

  def prefix
    "#{method_name}.#{klass.name.tableize}"
  end
end
