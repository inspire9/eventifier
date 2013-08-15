require 'active_support/concern'

module Eventifier
  module EventMixin

    extend ActiveSupport::Concern

    included do
      belongs_to :user
      belongs_to :eventable, :polymorphic => true
      has_many :notifications, :class_name => 'Eventifier::Notification',
        :dependent => :destroy

      validates :user, :presence => true
      validates :eventable, :presence => true
      validates :verb, :presence => true
    end

    module ClassMethods

      def add_notification(*arg)
        observer_instances.each { |observer| observer.add_notification(*arg) }
      end

      def add_url(*arg)
        observer_instances.each { |observer| observer.add_url(*arg) }
      end

      def create_event(verb, object, options = { })
        return if Eventifier.suspended?

        changed_data = object.changes.stringify_keys
        changed_data = changed_data.reject { |attribute, value| options[:except].include?(attribute) } if options[:except]
        changed_data = changed_data.select { |attribute, value| options[:only].include?(attribute) } if options[:only]
        self.create(
          :user => object.user,
          :eventable => object,
          :verb => verb,
          :change_data => changed_data.symbolize_keys
        )
      end

      def find_all_by_eventable object
        where :eventable_id => object.id, :eventable_type => object.class.name
      end
    end
  end
end
