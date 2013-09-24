class Eventifier::NotificationTranslator
  def initialize(prefix, delivery, *args)
    @prefix, @delivery = prefix, delivery
    @event  = ActiveSupport::Notifications::Event.new(*args).payload[:event]
  end

  def translate
    users_and_relations do |user, relations|
      next if user == event.user

      Eventifier::Notification.create event: event, user: user,
        relations: relations

      Eventifier::Delivery.deliver_for user if delivery == :immediate
    end
  end

  private

  attr_reader :event, :prefix, :delivery

  def users_and_relations(&block)
    Eventifier::NotificationMapping.users_and_relations event, prefix, &block
  end
end
