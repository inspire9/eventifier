require 'eventifier/event_observer_mixin'

module Eventifier
  class EventObserver < Mongoid::Observer
    include Eventifier::EventObserverMixin
  end
end