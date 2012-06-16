require 'active_support/concern'

module Eventifier
  module EventObserverMethods
    extend ActiveSupport::Concern

    include do
      observe Eventifier::Event
    end

    module InstanceMethods
      def add_notification klass_name, relation, method
        observed_classes.each do |observed_class|
          notification_mappings[klass_name.name]         ||= { }
          notification_mappings[klass_name.name][method] = relation
        end
      end

      def after_create event
        Rails.logger.info "Firing #{event.eventable_type}##{event.verb} - #{notification_mappings[event.eventable_type][event.verb]}" if notification_mappings.has_key?(event.eventable_type) and notification_mappings[event.eventable_type].has_key?(event.verb) and defined?(Rails)
        method_from_relation(event.eventable, notification_mappings[event.eventable_type][event.verb]).each do |user|
          next if user == event.user
          Eventifier::Notification.create :event => event, :user => user
        end if notification_mappings.has_key?(event.eventable_type) and notification_mappings[event.eventable_type].has_key?(event.verb)
      end

      def method_from_relation object, relation
        if relation.kind_of?(Hash)
          method_from_relation(proc { |object, method| object.send(method) }.call(object, relation.keys.first), relation.values.first)
        else
          send_to = proc { |object, method| object.send(method) }.call(object, relation)
          send_to = send_to.kind_of?(Array) ? send_to : [send_to]
        end
      end

      private

      def notification_mappings
        @notification_mapppings ||= { }
      end
    end
  end

  if defined? ActiveRecord

    class EventObserver < ActiveRecord::Observer
      include Eventifier::EventObserverMethods

    end
  elsif defined? Mongoid

    class EventObserver < Mongoid::Observer
      include Eventifier::EventObserverMethods

    end
  end
end