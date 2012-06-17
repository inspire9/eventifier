require 'active_support/concern'

module Eventifier

  module NotificationMethods
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
      # TODO: Are we okay to have notifier sit on the gem? How is this going to be handled?
      Eventifier::NotificationMailer.notification_email(self).deliver
    end
  end
  if defined? ActiveRecord

    class Notification < ActiveRecord::Base
      include Eventifier::NotificationMethods

      default_scope order("created_at DESC")
      scope :for_events, lambda { |ids| where(:event_id => ids) }
      scope :for_user, lambda { |user| where(:user_id => user.id) }
      scope :since, lambda { |date| where("created_at > ?", date) }

      scope :latest, order('notifications.created_at DESC').limit(5)
    end
  elsif defined? Mongoid

    class Notification
      include Mongoid::Document
      include Mongoid::Timestamps
      include Eventifier::NotificationMethods

      default_scope order_by([:created_at, :desc])
      scope :for_events, ->(ids) { where(:event_id => ids) }
      scope :for_user, ->(user) { where(:user_id => user.id) }
      scope :since, ->(date) { where(:created_at.gt => date) }
      scope :latest, order_by([:created_at, :desc]).limit(5)

      index({ user_id: 1})
      index({ event_id: 1})
      #index({ parent_id: 1})
    end
  end
end