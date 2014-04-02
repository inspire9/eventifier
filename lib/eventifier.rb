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

require "rails/observers/activerecord/active_record"

require 'multi_json'
require 'action_mailer'

require 'compass-rails'
require 'haml-rails'
require 'haml_coffee_assets'
require 'jbuilder'

module Eventifier
  mattr_accessor :mailer_sender
  self.mailer_sender = nil

  mattr_accessor :mailer_name
  self.mailer_name = "::Eventifier::Mailer"

  mattr_accessor :user_model_name
  self.user_model_name = 'User'

  def self.setup
    yield self
  end

  def self.mailer
    ActiveSupport::Dependencies.constantize(@@mailer_name)
  end

  def self.tracked_classes
    @tracked_classes ||= []
  end

  def self.resume!
    @suspended = false
  end

  def self.suspend(&block)
    suspend!
    yield
    resume!
  end

  def self.suspend!
    @suspended = true
  end

  def self.suspended?
    @suspended
  end
end


require 'eventifier/delivery'
require 'eventifier/event_tracking'
require 'eventifier/event_builder'
require 'eventifier/event_translator'
require 'eventifier/event_subscriber'
require 'eventifier/notification_translator'
require 'eventifier/preferences'
require 'eventifier/relationship'
require 'eventifier/trackable_class'
require 'eventifier/tracker'

require 'eventifier/notifier/notification_mapping'
require 'eventifier/notifier/notification_subscriber'
require 'eventifier/notifier/notifier'

require 'eventifier/mailers/helpers'

require 'eventifier/engine' if defined?(Rails)
