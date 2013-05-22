require 'active_support/concern'

module Eventifier
  module EventMixin

    extend ActiveSupport::Concern

    included do
      belongs_to :user
      belongs_to :eventable,    polymorphic: true
      has_many :notifications,  class_name: 'Eventifier::Notification', dependent: :destroy

      validates :user,      presence: true
      validates :eventable, presence: true
      validates :verb,      presence: true
    end

    module ClassMethods

      def add_notification(*arg)
        observer_instances.each { |observer| observer.add_notification(*arg) }
      end

      def add_url(*arg)
        observer_instances.each { |observer| observer.add_url(*arg) }
      end

      def find_all_by_eventable object
        where :eventable_id => object.id, :eventable_type => object.class.name
      end
    end
  end
end