require 'spec_helper'

describe Eventifier::NotificationMailer do
  describe "#notification_email" do
    before { Eventifier::NotificationMailer.any_instance.stub url_for: '/post' }

    it "should response to notification emails" do
      Eventifier::NotificationMailer.should respond_to(:notification_email)
    end

    it "should be able to send a 'notification' email" do
      proc { Eventifier::NotificationMailer.notification_email(Fabricate(:notification)).deliver }.should change(ActionMailer::Base.deliveries, :count)
    end
  end
end