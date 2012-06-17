require 'eventifier/event_mixin'

module Eventifier
  class Event < ActiveRecord::Base
    include Eventifier::EventMixin

    serialize :change_data
  end
end