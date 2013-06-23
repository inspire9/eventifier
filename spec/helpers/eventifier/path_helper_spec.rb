require 'spec_helper'

describe Eventifier::PathHelper do
  let(:notification) { double(Eventifier::Notification, event: double(Eventifier::Event, eventable_type: 'AwesomeObject')) }

  describe "partial_path" do
    it "returns an app view path with context in the path" do
      helper.partial_path(notification, :donkey).should == 'eventifier/donkey/notification'
    end

    it "returns an app view if it's defined" do
      helper.partial_path(notification, :dropdown).should == 'eventifier/dropdown/awesome_object'
    end

    it "returns the default view if not defined" do
      helper.partial_path(notification).should == 'eventifier/notification'
    end
  end
end
