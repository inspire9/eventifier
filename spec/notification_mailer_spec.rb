require 'spec_helper'

describe Eventifier::Mailer do
  describe "#notification_email" do
    before do
      Eventifier::Mailer.any_instance.stub main_app: double('app', url_for: true)
    end

    it "should response to notification emails" do
      Eventifier::Mailer.should respond_to(:notifications)
    end

    it "should be able to send a 'notification' email" do
      proc { Eventifier::Mailer.notifications(Fabricate(:notification)).deliver }.should change(ActionMailer::Base.deliveries, :count)
    end
  end
end