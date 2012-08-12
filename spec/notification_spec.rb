require 'spec_helper'

describe Eventifier::Notification do
  let(:notification) { Fabricate(:notification) }

  describe '.expire_for_past_events!' do
    let(:notification) { double('notification', :expire! => true) }
    let(:expired_event_ids) { [1, 3, 5, 7] }

    before :each do
      Eventifier::Event.stub :expired_ids => expired_event_ids
      Eventifier::Notification.stub :for_events => [notification]
    end

    it "finds all notifications belonging to past activities" do
      Eventifier::Notification.should_receive(:for_events).with(expired_event_ids).
        and_return([notification])

      Eventifier::Notification.expire_for_past_events!
    end

    it "expires each notification" do
      notification.should_receive(:expire!)

      Eventifier::Notification.expire_for_past_events!
    end
  end

  describe ".unread_for" do
    before { Eventifier::NotificationMailer.any_instance.stub post_path: '/post' }

    it "should return unread notifications for a user" do
      user = notification.user
      Eventifier::Notification.unread_for(user).should include notification
    end

    it "should return unread notifications for a user" do
      user = notification.user

      user.notifications_last_read_at = Time.now
      second_notification = Fabricate(:notification)

      Eventifier::Notification.unread_for(user).should_not include notification
      Eventifier::Notification.unread_for(user).should_not include second_notification
    end
  end

  describe "#create" do
    before { Eventifier::NotificationMailer.any_instance.stub post_path: '/post' }

    it "sends an email to the user" do
      ActionMailer::Base.deliveries.clear
      notification = Fabricate(:notification)
      ActionMailer::Base.deliveries.count.should > 0
    end
  end

  describe "#unread_for?" do
    let(:user)  { double(User, :notifications_last_read_at => last_read) }
    subject     { Fabricate.build(:notification, :created_at => Time.now).unread_for?(user) }
    context 'when the user has never read notifications' do
      let(:last_read) { nil }
      it 'should return true' do
        subject.should be_true
      end
    end
    context 'when the user has read notifications before' do

      describe 'notificication newer than that time' do
        let(:last_read) { Time.now - 1.day }

        it { should be_true }
      end
      describe 'notificication older than that time' do
        let(:last_read) { Time.now + 1.day }

        it { should be_false }
      end
    end
  end
end
