class Eventifier::Delivery
  def self.deliver
    unsent = Eventifier::Notification.unsent
    unsent.group_by(&:user).each do |user, notifications|
      new(user, notifications).deliver
    end
  end

  def initialize(user, notifications)
    @user, @notifications = user, notifications
  end

  def deliver
    if anything_to_send?
      Eventifier.mailer.notifications(user, notifications_to_send).deliver
    end

    notifications.each do |notification|
      notification.update_attribute :sent, true
    end
  end

  private

  attr_reader :user, :notifications

  def anything_to_send?
    !notifications_to_send.empty?
  end

  def notifications_to_send
    @notifications_to_send ||= notifications.select { |notification|
      include_notification? notification
    }
  end

  def settings
    @settings ||= Eventifier::NotificationSetting.for_user user
  end

  def include_notification?(notification)
    return true if settings.preferences['email'].nil?

    specifics = notification.relations.collect { |relation|
      key = [
        notification.event.verb,
        notification.event.eventable_type.underscore.pluralize,
        'notify',
        Eventifier::Relationship.new(self, relation).key
      ].join('_')
      settings.preferences['email'][key]
    }.compact

    return specifics.any? unless specifics.empty?

    default  = settings.preferences['email']['default']
    default.nil? || default
  end
end
