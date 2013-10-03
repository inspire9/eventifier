class Eventifier::NotificationTranslator
  def initialize(prefix, options, *args)
    @prefix, @options = prefix, options
    @event  = ActiveSupport::Notifications::Event.new(*args).payload[:event]
  end

  def translate
    return if skip?
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

  def skip?(user = nil)
    if conditional
      !conditional_call *[event.eventable, user][0..conditional.arity-1]
    else
      false
    end
  end

  def conditional
    options[:if] || options[:unless]
  end

  def conditional_call(*args)
    if options[:if]
      conditional.call(*args)
    else
      !conditional.call(*args)
    end
  end

  def users_and_relations(&block)
    Eventifier::NotificationMapping.users_and_relations event, prefix, &block
  end
end
