module Eventifier
  class Event < ::ActiveRecord::Base

    belongs_to :user
    belongs_to :eventable, :polymorphic => true
    has_many :notifications

    serialize :change_data

    validates :user, :presence => true
    validates :eventable, :presence => true
    validates :verb, :presence => true

    def self.add_notification(*arg)
      observer_instances.each { |observer| observer.add_notification(*arg) }
    end


    def self.create_event(verb, object, options = {})
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

    def self.find_all_by_eventable object
      where :eventable_id => object.id, :eventable_type => object.class.name
    end
  end
end