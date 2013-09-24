module Eventifier
  class Tracker
    def initialize klasses, methods, options
      @klasses   = klasses
      methods    = methods.kind_of?(Array) ? methods : [methods]
      raise 'No events defined to track' if methods.compact.empty?

      User.class_eval {
        has_many :notifications, class_name: 'Eventifier::Notification'
      } unless User.respond_to?(:notifications)
      User.class_eval {
        has_one :notification_setting,
                class_name: 'Eventifier::NotificationSetting',
                dependent: :destroy
      } unless User.respond_to?(:notification_setting)



      # set up each class with an observer and relationships
      @klasses.each do |target_klass|
        Eventifier::TrackableClass.track target_klass, methods, options
      end
    end
  end
end
