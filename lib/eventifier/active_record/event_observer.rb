require 'eventifier/notifier/event_observer_mixin'

module Eventifier
  class EventObserver < ActiveRecord::Observer
    include Eventifier::EventObserverMixin

  end
end
