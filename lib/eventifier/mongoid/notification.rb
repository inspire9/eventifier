require 'eventifier/notification_mixin'

module Eventifier
  class Notification
    include Mongoid::Document
    include Mongoid::Timestamps
    include Eventifier::NotificationMixin

    attr_accessor :url

    default_scope order_by([:created_at, :desc])
    scope :for_events, ->(ids) { where(:event_id => ids) }
    scope :for_user, ->(user) { where(:user_id => user.id) }
    scope :since, ->(date) { where(:created_at.gt => date) }
    scope :latest, order_by([:created_at, :desc]).limit(5)

    index({ user_id: 1 })
    index({ event_id: 1 })
    #index({ parent_id: 1})
  end
end