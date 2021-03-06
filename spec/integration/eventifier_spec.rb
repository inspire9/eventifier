require 'spec_helper'

describe Eventifier do
  it "can list tracked classes" do
    Object.new.extend(Eventifier::EventTracking).events_for Post do
      track_on [:create, :update], :attributes => { :except => %w(updated_at) }
      notify :readers, :on => [:create, :update]
    end

    expect(Eventifier.tracked_classes).to eq [Post]
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

      expect(Eventifier::Notification.where(
        :event_id => event.id, :user_id => owner.id
        ).count).to eq 0
    end

    it "stores notifications for the reader" do
      post.save

      [reader1, reader2].each do |reader|
        expect(Eventifier::Notification.where(
          :event_id => event.id, :user_id => reader.id
        ).count).to eq 1
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

      expect(event.groupable).to eq post
    end

    it "deletes the event when the post is destroyed" do
      post.save
      post.destroy

      Eventifier::Event.count.should be_zero
    end

    it "deletes notifications belonging to an event" do
      post.save
      post.destroy

      Eventifier::Notification.count.should be_zero
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

      expect(Eventifier::Notification.where(
        :event_id => event.id, :user_id => owner.id
      ).count).to eq 0
    end

    it "stores notifications for the reader" do
      post.update_attribute(:title, 'something else')

      [reader1, reader2].each do |reader|
        expect(Eventifier::Notification.where(
          :event_id => event.id, :user_id => reader.id
        ).count).to eq 1
      end
    end

    it "should create a notification for the reader when it's changed" do
      post.update_attribute(:title, 'somethang')

      [reader1, reader2].each do |reader|
        expect(reader.notifications.count).to eq 1
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

describe 'immediate email delivery' do
  let(:author) { Fabricate :user }
  let(:post)   { Fabricate :post, author: author }

  before do
    ActionMailer::Base.deliveries.clear

    Object.new.extend(Eventifier::EventTracking).events_for Like do
      track_on [:create]
      notify likeable: :user, on: [:create], email: :immediate
    end
  end

  it "emails the readers with a notification automatically" do
    Like.create! user: Fabricate(:user), likeable: post

    ActionMailer::Base.deliveries.detect { |email|
      email.to      == [author.email] &&
      email.subject == 'You have received notifications'
    }.should be_present
  end
end
