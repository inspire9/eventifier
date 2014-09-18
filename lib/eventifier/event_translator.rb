class Eventifier::EventTranslator
  def initialize(*args)
    @event = ActiveSupport::Notifications::Event.new *args
  end

  def translate
    return unless conditional_call

    Eventifier::EventBuilder.store payload[:object], user, payload[:event],
      groupable, options.except(:if, :unless)
  end

  private

  attr_reader :event

  delegate :payload, to: :event

  def conditional
    options[:if] || options[:unless]
  end

  def conditional_call
    if options[:if]
      conditional.call payload[:object]
    elsif options[:unless]
      !conditional.call payload[:object]
    else
      true
    end
  end

  def groupable
    payload[:group_by] ? relationship(payload[:group_by]) : payload[:object]
  end

  def options
    payload[:options] || {}
  end

  def relationship(key)
    Eventifier::Relationship.new(payload[:object], key).users.first
  end

  def user
    payload[:user] ? relationship(payload[:user]) : payload[:object].user
  end
end
