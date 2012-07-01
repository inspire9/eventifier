require 'spec_helper'

describe Eventifier::NotificationHelper do

  class TestClass
    def self.helper_method(*args); end
    include Eventifier::NotificationHelper
  end

  let!(:helper) {TestClass.new}

  before do
    @notification_strings = {
      :post => {
        :create => "{{user.name}} just created an Post - you should check it out",
        :destroy => "{{user.name}} just deleted an Post",
        :update => {
          :single => "{{user.name}} made a change to their Post",
          :multiple => "{{user.name}} made some changes to their Post",
          :attributes => {
            :deleted_at => "{{user.name}} deleted their Post"
          }
        }
      }
    }
    I18n.backend.store_translations :en, :notifications => @notification_strings
  end

  describe ".notification_message" do
    it "should return the I18n message for that event" do

      event = Fabricate(:event, :eventable => Fabricate(:post), :verb => :create)
      helper.notification_message(event).should == "<strong>#{event.user.name}</strong> just created an Post - you should check it out"
    end

    it "should return a message specific to a single change if only 1 change has been made" do
      event = Fabricate(:event, :eventable => Fabricate(:post), :verb => :update, :change_data => { :name => ["Fred", "Mike"] })
      helper.notification_message(event).should == "<strong>#{event.user.name}</strong> made a change to their Post"
    end
    it "should return a message specific to a particular field change if configuration is present" do
      event = Fabricate(:event, :eventable => Fabricate(:post), :verb => :update, :change_data => { :deleted_at => [nil, Time.now] })
      helper.notification_message(event).should == "<strong>#{event.user.name}</strong> deleted their Post"
    end

    it "should return a message specific to multiple changes if more than 1 change has been made" do
      event = Fabricate(:event, :eventable => Fabricate(:post), :verb => :update, :change_data => { :name => ["Fred", "Mike"], :age => [55, 65] })
      helper.notification_message(event).should == "<strong>#{event.user.name}</strong> made some changes to their Post"
    end

    it "should return the default I18n message if one doesn't exist" do
      I18n.backend.reload!
      @notification_strings = {
        :default => {
          :create => "{{user.name}} created a {{eventable_type}}",
          :update => "{{user.name}} updated a {{eventable_type}}"
        }
      }
      I18n.backend.store_translations :test, :notifications => @notification_strings
      I18n.with_locale("test") do
        event = Fabricate(:event, :eventable => Fabricate(:post), :verb => :create)
        helper.notification_message(event).should == "<strong>#{event.user.name}</strong> created a <strong>Post</strong>"
      end
    end
  end
end
