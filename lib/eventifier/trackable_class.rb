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

    create_callbacks

    observer.instance
  end

  private
  def add_relations
    @klass.class_eval { has_many :events, :as => :eventable, :class_name => 'Eventifier::Event', :dependent => :destroy }
    add_notification_association(@klass)
  end

  # create a callback for the methods we want to track
  def create_callbacks
    methods = @klass_methods
    attributes = @attributes

    observer.class_eval do
      methods.each do |event|
        define_method "after_#{event}" do |object|
          # create an event when the callback is fired
          Eventifier::Event.create_event(event.to_sym, object, attributes) if object.changed?
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
end