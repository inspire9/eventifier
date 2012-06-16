require 'spec_helper'

describe Eventifier do
  let(:post) { Fabricate(:post) }
  let(:group) { double('group', :user => owner, :members => [owner, member]) }
  let(:owner) { Fabricate(:user) }
  let(:member) { double('member') }

  before :each do
    Eventifier::Notification.stub :create => true
    post.stub(:group => group)
  end

  context 'a new post' do
    let(:event) { Eventifier::Event.new :eventable => post, :verb => :create,
                                        :user => owner }

    it "notifies the members of the group" do
      Eventifier::Notification.should_receive(:create).
        with(:user => member, :event => event)
        event.save
    end

    it "does not notify the person initiating the event" do
      Eventifier::Notification.should_not_receive(:create).
        with(:user => owner, :event => event)

      event.save
    end
  end

  context 'an existing post' do
    let(:event) { Eventifier::Event.new :eventable => post, :verb => :update,
                                        :user => owner }
    let(:guest) { double('guest') }

    before :each do
      post.group.stub :members => [owner, guest]
    end

    it "notifies the members of the post" do
      Eventifier::Notification.should_receive(:create).
        with(:user => guest, :event => event)
        event.save
    end

    it "does not notify the person initiating the event" do
      Eventifier::Notification.should_not_receive(:create).
        with(:user => owner, :event => event)

        event.save
    end

    # it "should create a notification for users of a post when it's changed" do
    #   post = event.eventable
    #   user = Fabricate(:user)
    #
    #   lambda { post.update_attribute :date, 5.days.from_now }.should change(user.notifications, :count).by(1)
    # end
  end

  context "helper method" do

    class TestClass
      def self.helper_method(*args)
      end

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
      helper.event_message(event).should == "<strong>#{event.user.name}</strong> just created a new post - you should check it out"
    end

    it "should return a message specific to a single change if only 1 change has been made" do
      event = Fabricate(:event,  :eventable => Fabricate(:post), :verb => :update, :change_data => { :name => ["Fred", "Mike"] })
      helper.event_message(event).should == "<strong>#{event.user.name}</strong> made a change to their post"
    end

    it "should return a message specific to multiple changes if more than 1 change has been made" do
      event = Fabricate(:event,  :eventable => Fabricate(:post), :verb => :update, :change_data => { :name => ["Fred", "Mike"], :age => [55, 65] })
      helper.event_message(event).should == "<strong>#{event.user.name}</strong> made some changes to their post"
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
        event = Fabricate(:event,  :eventable => Fabricate(:post), :verb => :create)
        helper.event_message(event).should == "<strong>#{event.user.name}</strong> created a <strong>Post</strong>"
      end
    end
  end

end