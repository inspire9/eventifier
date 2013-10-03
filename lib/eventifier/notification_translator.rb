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
    return !options[:if].call(event.eventable, user)    if options[:if] and options[:if].arity == 2
    return options[:unless].call(event.eventable, user) if options[:unless] and options[:unless].arity == 2
    return !options[:if].call(event.eventable)    if options[:if] and options[:if].arity == 1
    return options[:unless].call(event.eventable) if options[:unless] and options[:unless].arity == 1

    false
  end

  def users_and_relations(&block)
    Eventifier::NotificationMapping.users_and_relations event, prefix, &block
  end
end
