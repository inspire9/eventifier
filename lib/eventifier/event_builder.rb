class Eventifier::EventBuilder
  def self.store(object, user, verb, groupable = nil, options = {})
    new(object, user, verb, groupable || object, options).store
  end

  def initialize(object, user, verb, groupable, options)
    @object, @user, @verb, @groupable, @options = object, user, verb,
      groupable, options
  end

  def store
    Eventifier::Event.create user: user, eventable: object,
      groupable: groupable, verb: verb, change_data: change_data,
      system: options[:system]
  end

  private

  attr_reader :object, :user, :verb, :groupable, :options

  def change_data
    changes = object.changes.stringify_keys

    changes.reject! { |attribute, value|
      options[:except].include?(attribute)
    } if options[:except]

    changes.select! { |attribute, value|
      options[:only].include?(attribute)
    } if options[:only]

    changes.symbolize_keys
  end
end
