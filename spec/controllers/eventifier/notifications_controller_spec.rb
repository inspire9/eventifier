require 'spec_helper'

describe Eventifier::NotificationsController do
  routes     { Eventifier::Engine.routes }

  describe '#touch' do
    let(:user) { double 'User', :update_attribute => true }

    before :each do
      sign_in user
    end

    it "updates the current user's notifications last read at" do
      user.should_receive(:update_attribute).
        with(:notifications_last_read_at, anything)

      post :touch
    end

    it "responds with JSON OK status" do
      post :touch

      expect(response.body).to eq ({'status' => 'OK'}.to_json)
    end
  end
end
