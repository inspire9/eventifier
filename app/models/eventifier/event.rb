module Eventifier
  class Event < ActiveRecord::Base
    self.table_name = 'eventifier_events'

    belongs_to  :user,          class_name: Eventifier.user_model_name
    belongs_to  :eventable,     polymorphic: true
    belongs_to  :groupable,     polymorphic: true
    has_many    :notifications, class_name: 'Eventifier::Notification',
      dependent: :destroy

    validates :user,      presence: true, unless: :system?
    validates :eventable, presence: true
    validates :verb,      presence: true
    validates :groupable, presence: true

    serialize :change_data

    def self.find_all_by_eventable object
      where :eventable_id => object.id, :eventable_type => object.class.name
    end
  end
end
