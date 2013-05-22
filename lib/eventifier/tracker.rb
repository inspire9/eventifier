class Eventifier::Tracker
  def initialize klasses, methods, options
    @klasses   = klasses
    methods    = methods.kind_of?(Array) ? methods : [methods]
    attributes = options.delete(:attributes) || {}
    raise 'No events defined to track' if methods.compact.empty?

    User.class_eval { has_many :notifications, :class_name => 'Eventifier::Notification' } unless User.respond_to?(:notifications)
    Eventifier::EventObserver.instance

    # set up each class with an observer and relationships
    @klasses.each do |target_klass|
      Eventifier::TrackableClass.track target_klass, methods, attributes
    end
  end
end