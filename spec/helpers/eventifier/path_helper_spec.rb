require 'spec_helper'

describe Eventifier::PathHelper do
  class TestClass
    def self.helper_method(*args); end
    include Eventifier::PathHelper
  end

  let(:notification) { double(Eventifier::Notification, event: double(Eventifier::Event, eventable_type: 'AwesomeObject')) }
  let!(:helper) { TestClass.new }

  describe "partial_path" do
    it "returns an app view path with context in the path" do
      pending
expect(      helper.partial_path(notification, :donkey)).to eq'eventifier/donkey/notification'
    end

    it "returns an app view if it's defined" do
      pending
expect(      helper.partial_path(notification, :dropdown)).to eq'eventifier/dropdown/awesome_object'
    end

    it "returns the default view if not defined" do
      pending
expect(      helper.partial_path(notification)).to eq'eventifier/notification'
    end
  end
end
