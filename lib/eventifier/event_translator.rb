class EventTranslator
  def initialize(*args)
    @event = ActiveSupport::Notifications::Event.new *args
  end

  def translate
    Eventifier::EventBuilder.store payload[:object], user, payload[:event],
      groupable, payload[:options]
  end

  private

  attr_reader :event

  delegate :payload, to: :event

  def groupable
    payload[:group_by] ? relationship(payload[:group_by]) : payload[:object]
  end

  def relationship(key)
    Eventifier::Relationship.new(payload[:object], key).users.first
  end

  def user
    payload[:user] ? relationship(payload[:user]) : payload[:object].user
  end
end
