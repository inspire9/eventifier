module Eventifier
  module EventTracking
    def events_for(klass, *args, &block)
      @klasses = klass.kind_of?(Array) ? klass : [klass]

      options = args[0] || { }

      methods    = options.delete(:track_on)
      attributes = options.delete(:attributes)

      if block.nil?
        track_on methods, :attributes => attributes
      else
        instance_eval(&block)
      end
    end

    def track_on methods, options = { }
      methods    = methods.kind_of?(Array) ? methods : [methods]
      attributes = options.delete(:attributes) || {}
      raise 'No events defined to track' if methods.compact.empty?

      User.class_eval { has_many :notifications, :class_name => 'Eventifier::Notification' } unless User.respond_to?(:notifications)
      Eventifier::EventObserver.instance

      # set up each class with an observer and relationships
      @klasses.each do |target_klass|
        TrackableClass.track target_klass, methods, attributes
      end
    end

    def notify *args
      # args will either be [:relation, {:on => :create}] or [{:relation => :second_relation, :on => :create}]
      # if its the first one, relation is the first in the array, otherwise treat the whole thing like a hash
      relation = args.delete_at(0) if args.length == 2
      args = args.first

      methods  = args.delete(:on)
      methods  = methods.kind_of?(Array) ? methods : [methods]
      relation ||= args

      @klasses.each do |target_klass|
        methods.each do |method|
          Eventifier::Event.add_notification target_klass, relation, method
        end
      end
    end

    def url url_proc
      @klasses.each do |target_klass|
        Eventifier::EventTracking.url_mappings[target_klass.name.underscore.to_sym] = url_proc
      end
    end

    def self.url_mappings
      @url_mapppings ||= {}
    end
  end
end