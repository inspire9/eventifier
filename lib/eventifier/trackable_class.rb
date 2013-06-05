class Eventifier::TrackableClass
  Eventifier::OBSERVER_CLASS = ActiveRecord::Observer

  def self.track(klass, klass_methods, attributes)
    self.new(klass, klass_methods, attributes).track
  end

  def initialize(klass, klass_methods, options)
    @klass, @klass_methods = klass, klass_methods

    @attributes = options.delete(:attributes) || {}
    @owner      = options.delete :owner
    @group_by   = options.delete :group_by
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
    @klass.class_eval { has_many :notifications, through: :events, class_name: 'Eventifier::Notification', dependent: :destroy }
  end

  def generate_observer_callbacks
    methods, attributes, klass, owner, group_by = @klass_methods, @attributes, @klass, @owner, @group_by

    observer.class_eval do
      methods.each do |method|
        define_method "after_#{method}" do |object|
          Rails.logger.debug "||ASN|| Instrument #{method}.#{klass.name.tableize}" if defined?(Rails)
          ActiveSupport::Notifications.instrument("#{method}.#{klass.name.tableize}.event.eventifier", event: method.to_sym, object: object, options: attributes, user: owner, group_by: group_by) if object.changed?
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