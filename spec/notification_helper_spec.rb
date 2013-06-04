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

  describe "#notification_message" do
    it "should return the I18n message for that event" do

      event = Fabricate(:event, :eventable => Fabricate(:post), :verb => :create)
      helper.notification_message(event).should == "<strong class='user'>#{event.user.name}</strong> just created an Post - you should check it out"
    end

    it "should return a message specific to a single change if only 1 change has been made" do
      event = Fabricate(:event, :eventable => Fabricate(:post), :verb => :update, :change_data => { :name => ["Fred", "Mike"] })
      helper.notification_message(event).should == "<strong class='user'>#{event.user.name}</strong> made a change to their Post"
    end
    it "should return a message specific to a particular field change if configuration is present" do
      event = Fabricate(:event, :eventable => Fabricate(:post), :verb => :update, :change_data => { :deleted_at => [nil, Time.now] })
      helper.notification_message(event).should == "<strong class='user'>#{event.user.name}</strong> deleted their Post"
    end

    it "should return a message specific to multiple changes if more than 1 change has been made" do
      event = Fabricate(:event, :eventable => Fabricate(:post), :verb => :update, :change_data => { :name => ["Fred", "Mike"], :age => [55, 65] })
      helper.notification_message(event).should == "<strong class='user'>#{event.user.name}</strong> made some changes to their Post"
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
        helper.notification_message(event).should == "<strong class='user'>#{event.user.name}</strong> created a <strong>Post</strong>"
      end
    end
  end

  describe "Event Helper" do

    class TestClass
      def self.helper_method(*args)
      end

      include Eventifier::NotificationHelper
    end

    let(:verb) { "update" }
    let(:change_data) { { } }
    let(:event) { double("Event", :verb => verb, :eventable_type => "Object", :change_data => change_data, :user => double("user", :name => "Willy")) }
    let!(:helper) { TestClass.new }

    before do
      helper.stub :replace_vars => double("String", :html_safe => true)
    end

    describe ".event_message" do
      subject { helper.event_message event }

      context "with event verb create" do
        let(:verb) { "create" }

        it "should hit the I18n verb definition for create & destroy" do
          I18n.should_receive(:translate).with("events.object.create", :default => :"events.default.create", "user.name" => "Willy", :"event.type" => "Object")

          subject
        end

        it "should pass the I18n translation to the replace_vars method" do
          I18n.should_receive(:translate).with("events.object.create", :default => :"events.default.create", "user.name" => "Willy", :"event.type" => "Object").and_return("A message")
          helper.should_receive(:replace_vars).with "A message", event

          subject
        end
      end

      context "with event verb update" do
        let(:verb) { "update" }

        context "multiple updates" do
          let(:change_data) { { :name => ["Lol", "Omg Lol"] } }

          it "should specify single on the verb for the I18n definition on update when there are just a single change" do
            I18n.should_receive(:translate).with("events.object.update.single", :default => :"events.default.update", "user.name" => "Willy", :"event.type" => "Object")

            subject
          end
        end

        context "multiple updates" do
          let(:change_data) { { :name => ["Lol", "Omg Lol"], :address => ["old", "new"] } }

          it "should specify single on the verb for the I18n definition on update when there are just a single change" do
            I18n.should_receive(:translate).with("events.object.update.multiple", :default => :"events.default.update", "user.name" => "Willy", :"event.type" => "Object")

            subject
          end

        end
      end

    end
  end

  describe "replacing vars" do

    class TestClass
      def self.helper_method(*args); end
      include Eventifier::NotificationHelper
    end

    let!(:helper) { TestClass.new }

    describe ".replace_vars" do
      let(:event) { Fabricate.build(:event)}

      it "should replace {{stuff}} with awesome" do
        message = "I'm really loving {{eventable.title}}"
        helper.replace_vars(message, event).should == "I'm really loving <strong>#{event.eventable.title}</strong>"
      end

      it "should replace multiple {{stuff}} with multiple awesome" do
        message = "I'm really loving {{eventable.title}} and all {{eventable.class.name}}s"
        helper.replace_vars(message, event).should == "I'm really loving <strong>#{event.eventable.title}</strong> and all <strong>Post</strong>s"
      end
    end

    describe ".load_event_for_template" do

      it "should add some handy methods to an event instance" do
        event = Fabricate(:event)
        event = helper.load_event_for_template event
        event.object.should == event.eventable
        event.object_type.should == event.eventable_type
      end

    end
  end

end
