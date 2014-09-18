require 'spec_helper'

describe "Internationalisation" do
  class TestClass
    include Eventifier::NotificationHelper
  end

  let!(:helper) { TestClass.new }

  it "should return the I18n message for that event" do
    event = Fabricate(:event, :eventable => Fabricate(:post), :verb => :create)
    expect(helper.event_message(event)).to eq "<strong class='user'>#{event.user.name}</strong> just created a new post - you should check it out"
  end

  it "should return a message specific to a single change if only 1 change has been made" do
    event = Fabricate(:event, :eventable => Fabricate(:post), :verb => :update, :change_data => { :name => ["Fred", "Mike"] })
    expect(helper.event_message(event)).to eq "<strong class='user'>#{event.user.name}</strong> made a change to their post"
  end

  it "should return a message specific to multiple changes if more than 1 change has been made" do
    event = Fabricate(:event, :eventable => Fabricate(:post), :verb => :update, :change_data => { :name => ["Fred", "Mike"], :age => [55, 65] })
    expect(helper.event_message(event)).to eq "<strong class='user'>#{event.user.name}</strong> made some changes to their post"
  end

  it "should return the default I18n message if one doesn't exist" do
    I18n.backend.reload!
    I18n.backend.store_translations :test, :events => {
      :default => {
        :create => "{{user.name}} created a {{eventable_type}}",
        :update => "{{user.name}} updated a {{eventable_type}}"
      }
    }

    I18n.with_locale("test") do
      event = Fabricate(:event, :eventable => Fabricate(:post), :verb => :create)
      expect(helper.event_message(event)).to eq "<strong class='user'>#{event.user.name}</strong> created a <strong>Post</strong>"
    end
  end
end
