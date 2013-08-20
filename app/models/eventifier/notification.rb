module Eventifier
  class Notification < ActiveRecord::Base
    attr_accessible :event, :user, :relations, :event_id, :user_id

    belongs_to :event, :class_name => 'Eventifier::Event'
    belongs_to :user

    serialize :relations, MultiJson

    validates :event, :presence => true
    validates :user, :presence => true
    validates :event_id, :uniqueness => { :scope => :user_id }

    scope :for_events,  -> ids { where(event_id: ids) }
    scope :for_user,    -> user { where(user_id: user.id) }
    scope :since,       -> date { where("created_at > ?", date) }
    scope :latest,      order('notifications.created_at DESC').limit(5)
    scope :unsent,      -> { where(sent: false) }

    def self.expire_for_past_events!(time_limit = 1.day.ago)
      self.for_events(Event.expired_ids(time_limit)).each &:expire!
    end

    def self.unread_for(user)
      if user.notifications_last_read_at
        for_user(user).since(user.notifications_last_read_at)
      else
        for_user(user)
      end
    end

    def unread_for?(user)
      return true if user.notifications_last_read_at.nil?
      created_at > user.notifications_last_read_at
    end
  end
end
