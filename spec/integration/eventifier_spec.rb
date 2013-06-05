require 'spec_helper'

describe Eventifier do
  it "can list tracked classes" do
    Object.new.extend(Eventifier::EventTracking).events_for Post do
      track_on [:create, :update], :attributes => { :except => %w(updated_at) }
      notify :readers, :on => [:create, :update]
    end

    Eventifier.tracked_classes.should == [Post]
  end
end

describe 'event tracking' do
  let(:owner)         { Fabricate(:user) }
  let(:reader1)       { Fabricate(:user) }
  let(:reader2)       { Fabricate(:user) }

  before do
    ActionMailer::Base.deliveries.clear

    post.readers = [owner, reader1, reader2]

    Object.new.extend(Eventifier::EventTracking).events_for Post do
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

    it "does not store a notification for the post creator" do
      post.save

      Eventifier::Notification.where(
        :event_id => event.id, :user_id => owner.id
      ).count.should == 0
    end

    it "stores notifications for the reader" do
      post.save

      [reader1, reader2].each do |reader|
        Eventifier::Notification.where(
          :event_id => event.id, :user_id => reader.id
        ).count.should == 1
      end
    end

    it "emails the readers with a notification" do
      post.save

      Eventifier::Delivery.deliver

      [reader1, reader2].each do |reader|
        ActionMailer::Base.deliveries.detect { |email|
          email.to      == [reader.email] &&
          email.subject == 'You have received notifications'
        }.should be_present
      end
    end

    it "stores the post as the groupable object" do
      post.save

      event.groupable.should == post
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

    it "does not store a notification for the post creator" do
      post.update_attribute(:title, 'something else')

      Eventifier::Notification.where(
        :event_id => event.id, :user_id => owner.id
      ).count.should == 0
    end

    it "stores notifications for the reader" do
      post.update_attribute(:title, 'something else')

      [reader1, reader2].each do |reader|
        Eventifier::Notification.where(
          :event_id => event.id, :user_id => reader.id
        ).count.should == 1
      end
    end

    it "should create a notification for the reader when it's changed" do
      post.update_attribute(:title, 'somethang')

      [reader1, reader2].each do |reader|
        reader.notifications.count.should == 1
      end
    end

    it "emails the readers with a notification" do
      post.update_attribute(:title, 'somethang')

      Eventifier::Delivery.deliver

      [reader1, reader2].each do |reader|
        ActionMailer::Base.deliveries.detect { |email|
          email.to      == [reader.email] &&
          email.subject == 'You have received notifications'
        }.should be_present
      end
    end
  end
end
