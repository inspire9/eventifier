class Eventifier::TrackableClass
  include Eventifier::NotificationTracking

  def self.track(klass, klass_methods, attributes)
    self.new(klass, klass_methods, attributes).track
  end

  def initialize(klass, klass_methods, attributes)
    @klass, @klass_methods, @attributes = klass, klass_methods, attributes
  end

  def track
    add_relations

    generate_observer_callbacks

    observer.instance

    Eventifier::EventSubscriber.subscribe_to_all @klass, @klass_methods
  end

  private
  def add_relations
    @klass.class_eval { has_many :events, as: :eventable, class_name: 'Eventifier::Event', dependent: :destroy }
    add_notification_association(@klass)
  end

  def generate_observer_callbacks
    methods, attributes, klass = @klass_methods, @attributes, @klass

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
      observer_klass.observe @klass

      observer_klass
    end
  end

  def observer_klass
    @observer_klass ||= if self.class.const_defined?("#{@klass}Observer")
      self.class.const_get("#{@klass}Observer")
    else
      constant_name = "#{@klass}Observer"
      klass         = Class.new(Eventifier::OBSERVER_CLASS)
      self.class.qualified_const_set(constant_name, klass)
    end
  end
end