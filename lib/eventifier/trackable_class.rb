class Eventifier::EventTracking::TrackableClass
  include Eventifier::NotificationTracking

  def self.track(klass, klass_methods, attributes)
    self.new(klass, klass_methods, attributes).track
  end

  def initialize(klass, klass_methods, attributes)
    @klass, @klass_methods, @attributes = klass, klass_methods, attributes
  end

  def track
    add_relations

    generate_callbacks

    observer.instance

    subscribe_to_events
  end

  private
  def add_relations
    @klass.class_eval { has_many :events, as: :eventable, class_name: 'Eventifier::Event', dependent: :destroy }
    add_notification_association(@klass)
  end

  # generate a callback on the observer for the methods we want to track
  def generate_callbacks
    methods = @klass_methods
    attributes = @attributes
    klass = @klass

    observer.class_eval do
      methods.each do |event|
        define_method "after_#{event}" do |object|
          ActiveSupport::Notifications.instrument("#{event}.#{klass.name.tableize}.eventifier", event: event.to_sym, object: object, options: attributes) if object.changed?
        end
      end
    end
  end

  def observer
    @observer ||= begin
      klass = self.class.const_get("#{@klass}Observer")
      klass.observe @klass

      klass
    end
  end

  def subscribe_to_events
    @klass_methods.each do |method_name|
      subscribe_to_method "#{method_name}.#{@klass.name.tableize}.eventifier"
    end
  end

  def subscribe_to_method name
    return if ActiveSupport::Notifications.notifier.listening?(name)

    ActiveSupport::Notifications.subscribe name do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)

      Eventifier::Event.create_event(event.payload[:event].to_sym, event.payload[:object], event.payload[:options])
    end
  end
end