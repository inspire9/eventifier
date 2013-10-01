class Eventifier::NotificationTranslator
  def initialize(prefix, options, *args)
    @prefix, @options = prefix, options
    @event  = ActiveSupport::Notifications::Event.new(*args).payload[:event]
  end

  def translate
    users_and_relations do |user, relations|
      next if user == event.user
      next if skip?(user)

      Eventifier::Notification.create event: event, user: user,
        relations: relations

      Eventifier::Delivery.deliver_for user if options[:email] == :immediate
    end
  end

  private

  attr_reader :event, :prefix, :options

  def skip?(user)
    return !options[:if].call(event, user)    if options[:if]
    return options[:unless].call(event, user) if options[:unless]

    false
  end

  def users_and_relations(&block)
    Eventifier::NotificationMapping.users_and_relations event, prefix, &block
  end
end
