class Eventifier::Delivery
  def self.deliver
    Eventifier::Notification.unsent.each do |notification|
      new(notification).deliver
    end
  end

  delegate :event, :user, :relations, :to => :notification

  def initialize(notification)
    @notification = notification
  end

  def deliver
    Eventifier.mailer.notifications(notification).deliver if send_email?

    notification.update_attribute :sent, true
  end

  private

  attr_reader :notification

  def settings
    @settings ||= Eventifier::NotificationSetting.for_user user
  end

  def send_email?
    return true if settings.preferences['email'].nil?

    specifics = relations.collect { |relation|
      key = [event.verb, event.eventable_type.underscore.pluralize, 'notify',
        Eventifier::Relationship.new(self, relation).key].join('_')
      settings.preferences['email'][key]
    }.compact

    return specifics.any? { |specific| specific } unless specifics.empty?

    default  = settings.preferences['email']['default']
    default.nil? || default
  end
end
