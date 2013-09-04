class Eventifier::NotificationTranslator
  def initialize(prefix, *args)
    @prefix = prefix
    @event  = ActiveSupport::Notifications::Event.new(*args).payload[:event]
  end

  def translate
    users_and_relations do |user, relations|
      next if user == event.user

      Eventifier::Notification.create event: event, user: user,
        relations: relations
    end
  end

  private

  attr_reader :event, :prefix

  def users_and_relations(&block)
    Eventifier::NotificationMapping.users_and_relations event, prefix, &block
  end
end
