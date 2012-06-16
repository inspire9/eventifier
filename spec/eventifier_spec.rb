require 'spec_helper'
describe Eventifier::EventTracking do

  let(:user) { Fabricate(:user) }
  let(:test_class) { Post }
  let(:object) { Fabricate.build(:post) }
  let(:event_tracker) { Object.new.extend(Eventifier::EventTracking) }

  after :all do
    Post.observers.disable :all
  end

  describe ".initialize" do

    it "should start" do
      event_tracker
    end

  end

  describe ".events_for" do

    it "should create the relation notifications for Users" do
      event_tracker.events_for test_class,
                               :track_on => [:create, :update, :destroy],
                               :attributes => { :except => %w(updated_at) }

      user.should respond_to(:notifications)
    end

  end

  describe "hash syntax" do

    describe "creating events" do

      let(:subject) do
        object.save
      end

      before do
        object.stub(:user).and_return(user)
        event_tracker.events_for test_class,
                                 :track_on => [:create, :update, :destroy],
                                 :attributes => { :except => %w(updated_at) }
      end


      it "should create an event with the relevant info" do
        changes = { :foo => 'bar', :bar => 'baz' }
        object.stub(:changes).and_return(changes)

        Eventifier::Event.should_receive(:create).with(:user => user, :eventable => object, :verb => :create, :change_data => changes)

        subject
      end
    end

  end

  describe '#create_event' do
    let(:object) { double('object', :changes => changes, :user => double(User)) }
    let(:changes) { { :foo => 'bar', :bar => 'baz', :bob => 'blah' } }
    let(:options) { { } }

    subject { Eventifier::Event.create_event(:create, object, options) }

    describe "exclude" do
      let(:options) { { :except => ['foo'] } }

      it 'should exclude the right attrs' do
        Eventifier::Event.should_receive(:create) do |attrs|
          attrs[:change_data].should == { :bar => 'baz', :bob => 'blah' }
        end
        subject
      end

    end
    describe "only" do
      let(:options) { { :only => ['foo'] } }

      it 'should exclude the right attrs' do
        Eventifier::Event.should_receive(:create) do |attrs|
          attrs[:change_data].should == { :foo => 'bar' }
        end
        subject
      end

    end

  end


  context "block syntax" do

    context "tracking" do
      let(:subject) do
        object.save
      end

      before do
        object.stub(:user).and_return(user)
      end

      it "should create an event with the relevant info" do
        changes = { :foo => 'bar', :bar => 'baz' }
        object.stub(:changes).and_return(changes)
        event_tracker.events_for test_class do
          track_on [:create, :destroy], :attributes => { :except => %w(updated_at) }
          track_on :update, :attributes => { :except => %w(updated_at) }
        end

        Eventifier::Event.should_receive(:create).with(:user => user, :eventable => object, :verb => :create, :change_data => changes)

        subject
      end

      it "should hit the track event twice" do
        event_tracker.should_receive(:track_on).exactly(2).times

        event_tracker.events_for test_class do
          track_on [:create, :destroy], :attributes => { :except => %w(updated_at) }
          track_on :update, :attributes => { :except => %w(updated_at) }
        end
      end

      context "notifying" do
        before do
          @event_observer_instance = Eventifier::EventObserver.instance
        end

        describe "#add_notification" do

          it "should add the notification to the notification hash" do
            @event_observer_instance.should_receive(:add_notification).with(test_class, :user, :create)

            event_tracker.events_for test_class do
              track_on :create, :attributes => { :except => %w(updated_at) }
              notify :user, :on => :create
            end
          end
        end

        it "should notify users when passed a hash" do
          subscriber = double('user')

          object.stub :category => double('category', :subscribers => [subscriber])

          Eventifier::Notification.should_receive(:create) do |args|
            args[:user].should == subscriber
            args[:event].eventable.should == object
          end

          event_tracker.events_for test_class do
            track_on :create, :attributes => { :except => %w(updated_at) }
            notify :category => :subscribers, :on => :create
          end

          object.save
        end


        it "should create a notification" do
          Eventifier::Notification.should_receive(:create)
          object.stub(:readers => [Fabricate.build(:user)])
          event_tracker.events_for test_class do
            track_on :create, :attributes => { :except => %w(updated_at) }
            notify :readers, :on => :create
          end

          object.save
        end

      end
    end

  end
end