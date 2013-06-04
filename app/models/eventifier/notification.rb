module Eventifier
  class Notification < ActiveRecord::Base
    attr_accessible :event, :user, :relations, :event_id, :user_id
    attr_accessor :relations

    belongs_to :event, :class_name => 'Eventifier::Event'
    belongs_to :user

    validates :event, :presence => true
    validates :user, :presence => true
    validates :event_id, :uniqueness => { :scope => :user_id }

    after_create :send_email

    default_scope order("notifications.created_at DESC")
    scope :for_events,  -> ids { where(event_id: ids) }
    scope :for_user,    -> user { where(user_id: user.id) }
    scope :since,       -> date { where("created_at > ?", date) }
    scope :latest,      order('notifications.created_at DESC').limit(5)

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

    def send_email
      Eventifier.mailer.notifications(self).deliver if send_email?
    end

    private

    def settings
      @settings ||= Eventifier::NotificationSetting.for_user user
    end

    def send_email?
      return true if settings.preferences['email'].nil?

      specifics = relations.collect { |relation|
        key = [event.verb, event.eventable_type.underscore, 'notify', relation].join('_')
        settings.preferences['email'][key]
      }.compact

      return specifics.any? { |specific| specific } unless specifics.empty?

      default  = settings.preferences['email']['default']
      default.nil? || default
    end
  end
end