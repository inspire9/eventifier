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
require 'action_mailer'

if defined? Mongoid
  require 'eventifier/mongoid_support'
elsif defined? ActiveRecord
  require 'eventifier/active_record_support'
end

require 'eventifier/helper_methods'
require 'eventifier/notification_mailer'
require 'eventifier/notification_helper'
require 'eventifier/event_helper'
require 'eventifier/event_tracking'
require 'eventifier/tracker'
require 'eventifier/notifier'
require 'eventifier/trackable_class'

require 'eventifier/railtie' if defined?(Rails)