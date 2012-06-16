require 'spec_helper'

describe Eventifier::EventHelper do

  class TestClass
    def self.helper_method(*args); end
    include Eventifier::HelperMethods
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
