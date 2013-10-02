require 'spec_helper'

describe Eventifier::NotificationTranslator do
  let(:translator) {
    Eventifier::NotificationTranslator.new 'foo', options, :bar
  }
  let(:options)    { {} }
  let(:event)      { double 'Event', user: double }
  let(:user_a)     { double 'User' }
  let(:user_b)     { double 'User' }

  before :each do
    stub_const 'ActiveSupport::Notifications::Event',
      double(new: double(payload: {event: event}))
    stub_const 'Eventifier::NotificationMapping', double
    stub_const 'Eventifier::Notification', double(create: double)
    stub_const 'Eventifier::Delivery', double(deliver_for: true)

    Eventifier::NotificationMapping.stub(:users_and_relations).
      and_yield(user_a, [:a]).and_yield(user_b, [:b])
  end

  describe '#translate' do
    it "creates a notification for each affected user" do
      Eventifier::Notification.should_receive(:create).
        with(event: event, user: user_a, relations: [:a])
      Eventifier::Notification.should_receive(:create).
        with(event: event, user: user_b, relations: [:b])

      translator.translate
    end

    it "does not create an event for the originator's user" do
      event.stub user: user_a

      Eventifier::Notification.should_not_receive(:create).
        with(event: event, user: user_a, relations: [:a])
      Eventifier::Notification.should_receive(:create).
        with(event: event, user: user_b, relations: [:b])

      translator.translate
    end

    it "creates an event when :if is set and returns true" do
      options[:if] = Proc.new { |event, user| true }

      Eventifier::Notification.should_receive(:create).
        with(event: event, user: user_a, relations: [:a])
      Eventifier::Notification.should_receive(:create).
        with(event: event, user: user_b, relations: [:b])

      translator.translate
    end

    it "does not create an event when :if is set and returns false" do
      options[:if] = Proc.new { |event, user| false }

      Eventifier::Notification.should_not_receive(:create).
        with(event: event, user: user_a, relations: [:a])
      Eventifier::Notification.should_not_receive(:create).
        with(event: event, user: user_b, relations: [:b])

      translator.translate
    end

    it "creates an event when :unless is set and returns false" do
      options[:unless] = Proc.new { |event, user| false }

      Eventifier::Notification.should_receive(:create).
        with(event: event, user: user_a, relations: [:a])
      Eventifier::Notification.should_receive(:create).
        with(event: event, user: user_b, relations: [:b])

      translator.translate
    end

    it "does not create an event when :unless is set and returns true" do
      options[:unless] = Proc.new { |event, user| true }

      Eventifier::Notification.should_not_receive(:create).
        with(event: event, user: user_a, relations: [:a])
      Eventifier::Notification.should_not_receive(:create).
        with(event: event, user: user_b, relations: [:b])

      translator.translate
    end

    it "does not deliver an email by default" do
      Eventifier::Delivery.should_not_receive(:deliver_for).with(user_a)
      Eventifier::Delivery.should_not_receive(:deliver_for).with(user_b)

      translator.translate
    end

    it "delivers email when :email is set to :immediate" do
      options[:email] = :immediate

      Eventifier::Delivery.should_receive(:deliver_for).with(user_a)
      Eventifier::Delivery.should_receive(:deliver_for).with(user_b)

      translator.translate
    end
  end
end
