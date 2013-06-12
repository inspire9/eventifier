require 'spec_helper'

describe Eventifier::PreferencesController do
  let(:user) { double 'User' }

  before :each do
    sign_in user

    Eventifier::Preferences.stub :new => preferences
  end

  describe '#show' do
    let(:preferences) { double :to_hashes => [{'foo' => 'bar'}] }

    it "returns the settings hashes" do
      get :show

      response.body.should == [{'foo' => 'bar'}].to_json
    end
  end

  describe '#update' do
    let(:preferences) { double to_hashes: [{:key => 'foo'}, {:key => 'bar'}] }
    let(:settings)    { double 'Settings', :preferences => {}, :save => true }

    before :each do
      Eventifier::NotificationSetting.stub :for_user => settings
    end

    it "updates the user's email preferences" do
      put :update, :preferences => {'foo' => ''}

      settings.preferences['email']['foo'].should be_true
      settings.preferences['email']['bar'].should be_false
    end

    it "sets everything to false if no preferences are supplied" do
      put :update

      settings.preferences['email']['foo'].should be_false
      settings.preferences['email']['bar'].should be_false
    end

    it 'saves the settings changes' do
      settings.should_receive(:save)

      put :update, :preferences => {'foo' => ''}
    end

    it "renders a JSON OK status" do
      put :update, :preferences => {'foo' => ''}

      response.body.should == {'status' => 'OK'}.to_json
    end
  end
end
