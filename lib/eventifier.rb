# Step 1. Use rails hooks for create and update and destroy
# Step 2. Use modules to overwrite methods, and be rails independent
# Consider implementing with http://stackoverflow.com/questions/3689736/rails-3-alias-method-chain-still-used
# Consider implementing with http://www.ruby-doc.org/stdlib-1.9.3/libdoc/observer/rdoc/Observable.html


# init.rb
# require 'eventifer'


# Todo
# - Notifications

# Ideas for implementation:


# class EventTracking
#   include Eventable::EventTracking
#
#   def initialize
#     events_for Activity,
#                :on => [:create, :update, :destroy],
#                :attributes => { :except => %w(updated_at) }
#   end
#
# end

require 'multi_json'
require 'action_mailer'

module Eventifier
  mattr_accessor :mailer_sender
  self.mailer_sender = nil

  mattr_accessor :mailer_name
  self.mailer_name = "::Eventifier::Mailer"

  def self.setup
    yield self
  end

  def self.mailer
    ActiveSupport::Dependencies.constantize(@@mailer_name)
  end
end

require 'eventifier/helpers/object_helper'

require 'eventifier/tracker'
require 'eventifier/event_tracking'
require 'eventifier/trackable_class'
require 'eventifier/event_subscriber'

require 'eventifier/notifier/notification_mapping'
require 'eventifier/notifier/notification_subscriber'
require 'eventifier/notifier/notifier'

require 'eventifier/mailers/helpers'

require 'eventifier/engine' if defined?(Rails)
