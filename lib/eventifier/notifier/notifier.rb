class Eventifier::Notifier
  OPTION_KEYS = [:email, :if, :unless, :notify_self]
  # arguments will either be [:relation, {:on => :create}] or
  # [{:relation => :second_relation, :on => :create}]
  # If it's the first one, relation is the first in the array, otherwise treat
  # the whole thing like a hash
  def initialize(klasses, *arguments)
    relation   = arguments.shift if arguments.length >= 2
    arguments  = arguments.first || {}

    methods    = Array arguments.delete(:on)
    options    = arguments.slice *OPTION_KEYS
    relation ||= arguments.except *OPTION_KEYS

    klasses.each do |target_klass|
      methods.each do |method_name|
        Eventifier::NotificationMapping.add "#{method_name}.#{target_klass.name.tableize}", relation
        Eventifier::NotificationSubscriber.subscribe_to_method target_klass, method_name, options
      end
    end
  end
end
