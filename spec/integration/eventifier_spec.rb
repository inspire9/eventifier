require 'spec_helper'

describe Eventifier do
  let(:post) { Fabricate(:post, :author => owner) }
  let(:owner) { Fabricate(:user) }
  let(:reader1) { Fabricate(:user) }
  let(:reader2) { Fabricate(:user) }


  let(:event_tracker) { Object.new.extend(Eventifier::EventTracking) }


  before :each do
    post.stub(:readers => [owner, reader1, reader2])

    event_tracker.events_for Post do
      track_on [:create, :update], :attributes => { :except => %w(updated_at) }
      notify :readers, :on => [:create, :update]
    end
  end

  context 'a new post' do
    let(:post) { Fabricate.build(:post, :author => owner) }

    it "notifies only the readers of the post" do
      Eventifier::Notification.should_receive(:create).twice do |args|
        args[:event].verb.should == :create
        [reader1, reader2].should include(args[:user])
      end
      post.save
    end
  end

  context 'an existing post' do
    let(:post) { Fabricate(:post, :author => owner) }

    let(:event) { Eventifier::Event.new :eventable => post, :verb => :update,
                                        :user => owner }

    it "notifies the readers of the post" do
      Eventifier::Notification.should_receive(:create).twice do |args|
        args[:event].verb.should == :update
        [reader1, reader2].should include(args[:user])
      end
      post.update_attribute(:title, 'something else')
    end

    it "should create a notification for readers of a post when it's changed" do
      lambda { post.update_attribute(:title, 'somethang') }.should change(reader1.notifications, :count).by(1)
    end
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
      event = Fabricate(:event, :eventable => Fabricate(:post), :verb => :update, :change_data => { :name => ["Fred", "Mike"] })
      helper.event_message(event).should == "<strong>#{event.user.name}</strong> made a change to their post"
    end

    it "should return a message specific to multiple changes if more than 1 change has been made" do
      event = Fabricate(:event, :eventable => Fabricate(:post), :verb => :update, :change_data => { :name => ["Fred", "Mike"], :age => [55, 65] })
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
        event = Fabricate(:event, :eventable => Fabricate(:post), :verb => :create)
        helper.event_message(event).should == "<strong>#{event.user.name}</strong> created a <strong>Post</strong>"
      end
    end
  end

end