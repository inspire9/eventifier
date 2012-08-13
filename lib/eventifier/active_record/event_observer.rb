require 'eventifier/event_observer_mixin'

module Eventifier
  class EventObserver < ActiveRecord::Observer
    include Eventifier::EventObserverMixin
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper

  end
end
