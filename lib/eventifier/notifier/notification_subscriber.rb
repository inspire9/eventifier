class Eventifier::NotificationSubscriber
  def self.subscribe_to_method(klass, method_name, delivery)
    new(klass, method_name, delivery).subscribe_to_method
  end

  def initialize(klass, method_name, delivery)
    @klass, @method_name, @delivery = klass, method_name, delivery
  end

  def subscribe_to_method
    return if notifications.notifier.listening?(name)

    notifications.subscribe(name) do |*args|
      Eventifier::NotificationTranslator.new(prefix, delivery, *args).translate
    end
  end

  private

  attr_reader :klass, :method_name, :delivery

  def name
    "#{prefix}.notification.eventifier"
  end

  def notifications
    ActiveSupport::Notifications
  end

  def prefix
    "#{method_name}.#{klass.name.tableize}"
  end
end
