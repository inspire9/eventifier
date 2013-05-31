require 'active_support/concern'

module Eventifier
  module NotificationMixin
    extend ActiveSupport::Concern

    included do
      belongs_to :event, :class_name => 'Eventifier::Event'
      belongs_to :user

      validates :event, :presence => true
      validates :user, :presence => true
      validates :event_id, :uniqueness => { :scope => :user_id }

      after_create :send_email
    end

    module ClassMethods
      def expire_for_past_events!(time_limit = 1.day.ago)
        self.for_events(Event.expired_ids(time_limit)).each &:expire!
      end

      def unread_for(user)
        if user.notifications_last_read_at
          for_user(user).since(user.notifications_last_read_at)
        else
          for_user(user)
        end
      end
    end

    def unread_for?(user)
      return true if user.notifications_last_read_at.nil?
      created_at > user.notifications_last_read_at
    end

    def send_email
      ::Eventifier::Mailer.notifications(self).deliver
    end
  end
end