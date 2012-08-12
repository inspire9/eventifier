require 'eventifier/notification_mixin'

module Eventifier
  class Notification < ActiveRecord::Base
    include Eventifier::NotificationMixin

    default_scope order("created_at DESC")
    scope :for_events,  -> ids { where(event_id: ids) }
    scope :for_user,    -> user { where(user_id: user.id) }
    scope :since,       -> date { where("created_at > ?", date) }
    scope :latest,      order('notifications.created_at DESC').limit(5)
  end
end