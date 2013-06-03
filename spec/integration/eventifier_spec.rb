require 'spec_helper'

describe Eventifier do
  let(:owner)         { Fabricate(:user) }
  let(:reader1)       { Fabricate(:user) }
  let(:reader2)       { Fabricate(:user) }
  let(:event_tracker) { Object.new.extend(Eventifier::EventTracking) }

  before do
    Eventifier::Mailer.any_instance.stub main_app: double('app', url_for: true)

    post.readers = [owner, reader1, reader2]

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
end
