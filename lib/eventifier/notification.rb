module Eventifier
  class Notification < ActiveRecord::Base
    belongs_to :event
    belongs_to :user

    default_scope order("created_at DESC")
    scope :for_events,  lambda { |ids| where(:event_id => ids) }
    scope :for_user,    lambda { |id| where(:user_id => id) }
    scope :latest,      order('notifications.created_at DESC').limit(5)

    validates :event,     :presence => true
    validates :user,      :presence => true
    validates :event_id,  :uniqueness => { :scope => :user_id }

    after_create :send_email

    def self.expire_for_past_events!(time_limit = 1.day.ago)
      self.for_events(Event.expired_ids(time_limit)).each &:expire!
    end

    def self.unread_for(user)
      if user.notifications_last_read_at
        for_user(user).
          where("notifications.created_at > ?", user.notifications_last_read_at)
      else
        for_user(user)
      end
    end

    def unread_for?(user)
      return true if user.notifications_last_read_at.nil?
      created_at > user.notifications_last_read_at
    end

    def send_email
      # TODO: Are we okay to have notifier sit on the gem? How is this going to be handled?
      Eventifier::NotificationMailer.notification_email(self).deliver
    end
  end
end