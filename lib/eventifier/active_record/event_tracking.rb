module Eventifier
  module EventTracking
    OBSERVER_CLASS = ActiveRecord::Observer

    def add_notification_association(target_klass)
      target_klass.class_eval do
        has_many :notifications, :through => :events, :class_name => 'Eventifier::Notification', :dependent => :destroy
      end
    end
  end
end