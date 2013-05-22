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

    def track_on methods, options = {}
      Eventifier::Tracker.new @klasses, methods, options
    end

    def notify *args
      Eventifier::Notifier.new @klasses, *args
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