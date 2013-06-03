require 'eventifier/event_mixin'

module Eventifier
  class Event < ActiveRecord::Base
    include Eventifier::EventMixin
    attr_accessible :user, :eventable, :verb, :change_data

    serialize :change_data
  end
end