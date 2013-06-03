require 'spec_helper'

describe "Internationalisation" do
  class TestClass
    include Eventifier::EventHelper
  end

  let!(:helper) { TestClass.new }
  before do
    @event_strings = {
      :post => {
        :create => "{{user.name}} just created a new post - you should check it out",
        :destroy => "{{user.name}} just deleted a post",
        :update => {
          :single => "{{user.name}} made a change to their post",
          :multiple => "{{user.name}} made some changes to their post"
        }
      }
    }
    I18n.backend.store_translations :en, :events => @event_strings
  end

  it "should return the I18n message for that event" do
    event = Fabricate(:event, :eventable => Fabricate(:post), :verb => :create)
    helper.event_message(event).should == "<strong class='user'>#{event.user.name}</strong> just created a new post - you should check it out"
  end

  it "should return a message specific to a single change if only 1 change has been made" do
    event = Fabricate(:event, :eventable => Fabricate(:post), :verb => :update, :change_data => { :name => ["Fred", "Mike"] })
    helper.event_message(event).should == "<strong class='user'>#{event.user.name}</strong> made a change to their post"
  end

  it "should return a message specific to multiple changes if more than 1 change has been made" do
    event = Fabricate(:event, :eventable => Fabricate(:post), :verb => :update, :change_data => { :name => ["Fred", "Mike"], :age => [55, 65] })
    helper.event_message(event).should == "<strong class='user'>#{event.user.name}</strong> made some changes to their post"
  end

  it "should return the default I18n message if one doesn't exist" do
    I18n.backend.reload!
    @event_strings = {
      :default => {
        :create => "{{user.name}} created a {{eventable_type}}",
        :update => "{{user.name}} updated a {{eventable_type}}"
      }
    }
    I18n.backend.store_translations :test, :events => @event_strings
    I18n.with_locale("test") do
      event = Fabricate(:event, :eventable => Fabricate(:post), :verb => :create)
      helper.event_message(event).should == "<strong class='user'>#{event.user.name}</strong> created a <strong>Post</strong>"
    end
  end
end
