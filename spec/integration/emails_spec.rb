require 'spec_helper'

describe 'Notification emails' do
  describe 'email templates' do
    #
  end

  describe 'notification preferences' do
    let(:user)     { Fabricate :user }
    let(:post)     { Fabricate.build :post }
    let(:settings) { Eventifier::NotificationSetting.for_user user }

    before :each do
      ActionMailer::Base.deliveries.clear

      Object.new.extend(Eventifier::EventTracking).events_for Post do
        track_on [:create, :update], :attributes => {:except => %w(updated_at)}
        notify :readers, :on => [:create, :update]
      end

      post.readers << user
    end

    def email
      Eventifier::Delivery.deliver

      ActionMailer::Base.deliveries.detect { |email|
        email.to      == [user.email] &&
        email.subject == 'You have received a notification'
      }
    end

    it "sends an email when no default or post settings" do
      settings.preferences['email'] = {}
      settings.save

      post.save

      email.should be_present
    end

    it "sends an email when default is true and no post setting" do
      settings.preferences['email'] = {'default' => true}
      settings.save

      post.save

      email.should be_present
    end

    it "does not send an email when default is false and no post setting" do
      settings.preferences['email'] = {'default' => false}
      settings.save

      post.save

      email.should_not be_present
    end

    it "sends an email when default and post are true" do
      settings.preferences['email'] = {
        'default' => true, 'create_posts_notify_readers' => true
      }
      settings.save

      post.save

      email.should be_present
    end

    it "sends an email when default is false but post is true" do
      settings.preferences['email'] = {
        'default' => false, 'create_posts_notify_readers' => true
      }
      settings.save

      post.save

      email.should be_present
    end

    it "does not send an email when default is true but post is false" do
      settings.preferences['email'] = {
        'default' => true, 'create_posts_notify_readers' => false
      }
      settings.save

      post.save

      email.should_not be_present
    end

    it "does not send an email when default and post are false" do
      settings.preferences['email'] = {
        'default' => false, 'create_posts_notify_readers' => false
      }
      settings.save

      post.save

      email.should_not be_present
    end
  end
end
