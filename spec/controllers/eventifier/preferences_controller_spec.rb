require 'spec_helper'

describe Eventifier::PreferencesController do
  routes     { Eventifier::Engine.routes }
  let(:user) { double 'User' }

  before :each do
    sign_in user

    Eventifier::Preferences.stub :new => preferences
  end

  describe '#show' do
    let(:preferences) { double :to_hashes => [{'foo' => 'bar'}] }

    it "returns the settings hashes" do
      get :show

      expect(response.body).to eq ([{'foo' => 'bar'}].to_json)
    end
  end

  describe '#update' do
    let(:preferences) { double update: true }

    it 'saves the settings changes' do
      preferences.should_receive(:update).with('foo' => '')

      put :update, :preferences => {'foo' => ''}
    end

    it "renders a JSON OK status" do
      put :update, :preferences => {'foo' => ''}

      expect(response.body).to eq ({'status' => 'OK'}.to_json)
    end
  end
end
