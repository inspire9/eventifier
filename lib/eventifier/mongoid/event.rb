require 'eventifier/event_mixin'

module Eventifier
  class Event
    include Mongoid::Document
    include Mongoid::Timestamps
    include Eventifier::EventMixin

    field :change_data, :type => Hash
    field :eventable_type, :type => String
    field :verb, :type => Symbol

    index({ user_id: 1 })
    index({ eventable_id: 1, eventable_type: 1 })
  end
end