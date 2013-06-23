require 'spec_helper'

describe Eventifier::Delivery do
  describe '#deliver' do
    let(:delivery)     { Eventifier::Delivery.new double, [notification] }
    let(:notification) { double 'Notification', relations: [:subscribers], event: event, update_attribute: true }
    let(:event)        { double 'Event', verb: 'create',
      eventable_type: 'Post' }
    let(:email)        { double 'Email', deliver: true }
    let(:settings)     { double 'Settings', preferences: {} }
    let(:mailer)       { double 'Mailer', notifications: email }

    before :each do
      Eventifier.stub mailer: mailer
      Eventifier::NotificationSetting.stub for_user: settings
    end

    shared_examples_for 'a delivered email' do
      it "sends the email" do
        email.should_receive(:deliver)

        delivery.deliver
      end

      it "updates the sent status of the notification" do
        notification.should_receive(:update_attribute).with(:sent, true)

        delivery.deliver
      end
    end

    shared_examples_for 'a blocked email' do
      it "does not send the email" do
        email.should_not_receive(:deliver)

        delivery.deliver
      end

      it "updates the sent status of the notification" do
        notification.should_receive(:update_attribute).with(:sent, true)

        delivery.deliver
      end
    end

    context 'no settings' do
      before :each do
        settings.preferences['email'] = {}
      end

      it_should_behave_like 'a delivered email'
    end

    context "default is set to true" do
      before :each do
        settings.preferences['email'] = {'default' => true}
      end

      it_should_behave_like 'a delivered email'
    end

    context "default is set to false" do
      before :each do
        settings.preferences['email'] = {'default' => false}
      end

      it_should_behave_like 'a blocked email'
    end

    context "default and post are set to true" do
      before :each do
        settings.preferences['email'] = {
          'default' => true, 'create_posts_notify_subscribers' => true
        }
      end

      it_should_behave_like 'a delivered email'
    end

    context "default is set to false but post is set to true" do
      before :each do
        settings.preferences['email'] = {
          'default' => false, 'create_posts_notify_subscribers' => true
        }
      end

      it_should_behave_like 'a delivered email'
    end

    context "default is set to true but post is set to false" do
      before :each do
        settings.preferences['email'] = {
          'default' => true, 'create_posts_notify_subscribers' => false
        }
      end

      it_should_behave_like 'a blocked email'
    end

    context "default and post are both set to false" do
      before :each do
        settings.preferences['email'] = {
          'default' => false, 'create_posts_notify_subscribers' => false
        }
      end

      it_should_behave_like 'a blocked email'
    end
  end
end
