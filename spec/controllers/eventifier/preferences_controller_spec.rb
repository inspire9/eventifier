require 'spec_helper'

describe Eventifier::PreferencesController do
  let(:user) { double 'User' }

  before :each do
    sign_in user
  end

  describe '#show' do
    let(:preferences) { double :to_hashes => [{'foo' => 'bar'}] }

    before :each do
      Eventifier::Preferences.stub :new => preferences
    end

    it "returns the settings hashes" do
      get :show

      response.body.should == [{'foo' => 'bar'}].to_json
    end
  end

  describe '#update' do
    let(:settings) { double 'Settings', :preferences => {}, :save => true }

    before :each do
      Eventifier::NotificationSetting.stub :for_user => settings
    end

    it "updates the user's email preferences" do
      put :update, :preferences => [{
        :key => 'create.posts', :value => false, :label => 'Create Posts'
      }]

      settings.preferences['email']['create.posts'].should be_false
    end

    it 'saves the settings changes' do
      settings.should_receive(:save)

      put :update, :preferences => [{
        :key => 'create.posts', :value => false, :label => 'Create Posts'
      }]
    end

    it "renders a JSON OK status" do
      put :update, :preferences => [{
        :key => 'create.posts', :value => false, :label => 'Create Posts'
      }]

      response.body.should == {'status' => 'OK'}.to_json
    end
  end
end
