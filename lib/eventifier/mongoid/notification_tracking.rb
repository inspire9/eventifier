module Eventifier
  module NotificationTracking
    Eventifier::OBSERVER_CLASS = Mongoid::Observer

    def add_notification_association target_klass
      target_klass.class_eval do
        define_method :notifications do
          events.map(&:notifications).flatten.compact
        end
      end
    end
  end
end