module Eventifier
  module Matchers
    class Notifications
      def initialize(target)
        @target = target
      end

      def matches?(block_to_test)
        #before = incidents_count
        existing_notifications = @target.inject({}) do |memo, record|
          memo[record] = record.notifications
        end
        block_to_test.call
        @target.none? do |record|
          (existing_notifications[record] - record.notifications).empty?
        end
      end

      def failure_message_for_should
        'should have worked'
        #"the block should have chronicled the '#{ @event_name }' incident for the #{ @target.class.name }##{ @target.object_id }, but it didn't"
      end

      def failure_message_for_should_not
        'should not have worked'
        #"the block should not have chronicled the '#{ @event_name }' incident for the #{ @target.class.name }##{ @target.object_id }, but it did"
      end
    end

    def create_notifications_for(target)
      Matchers::Notifications.new(target)
    end
  end
end