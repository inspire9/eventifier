require 'spec_helper'

describe Eventifier::NotificationMailer do
  describe "#notification_email" do
    before do
      Eventifier::NotificationMailer.any_instance.stub main_app: double('app', url_for: true)
    end

    it "should response to notification emails" do
      Eventifier::NotificationMailer.should respond_to(:notification_email)
    end

    it "should be able to send a 'notification' email" do
      proc { Eventifier::NotificationMailer.notification_email(Fabricate(:notification)).deliver }.should change(ActionMailer::Base.deliveries, :count)
    end
  end
end