require 'spec_helper'

describe Eventifier do
  let(:owner)         { Fabricate(:user) }
  let(:reader1)       { Fabricate(:user) }
  let(:reader2)       { Fabricate(:user) }
  let(:event_tracker) { Object.new.extend(Eventifier::EventTracking) }

  before do
    post.readers = [owner, reader1, reader2]

    event_tracker.events_for Post do
      track_on [:create, :update], :attributes => { :except => %w(updated_at) }
      notify :readers, :on => [:create, :update]
    end
  end

  context 'a new post' do
    let(:post)  { Fabricate.build(:post, :author => owner) }
    let(:event) {
      Eventifier::Event.where(
        :verb => :create,          :user_id => owner.id,
        :eventable_type => 'Post', :eventable_id => post.id
      ).first
    }

    it "logs an event" do
      post.save

      event.should be_present
    end

    it "notifies only the readers of the post" do
      post.save

      Eventifier::Notification.where(
        :event_id => event.id, :user_id => reader1.id
      ).count.should == 1

      Eventifier::Notification.where(
        :event_id => event.id, :user_id => reader2.id
      ).count.should == 1
    end
  end

  context 'an existing post' do
    let(:post)  { Fabricate(:post, :author => owner) }
    let(:event) {
      Eventifier::Event.where(
        :verb => :update,          :user_id => owner.id,
        :eventable_type => 'Post', :eventable_id => post.id
      ).first
    }

    it "logs an event" do
      post.update_attribute :title, 'somethang'

      event.should be_present
    end

    it "notifies the readers of the post" do
      post.update_attribute(:title, 'something else')

      Eventifier::Notification.where(
        :event_id => event.id, :user_id => reader1.id
      ).count.should == 1

      Eventifier::Notification.where(
        :event_id => event.id, :user_id => reader2.id
      ).count.should == 1
    end

    it "should create a notification for readers of a post when it's changed" do
      lambda {
        post.update_attribute(:title, 'somethang')
      }.should change(reader1.notifications, :count).by(1)
    end
  end
end
