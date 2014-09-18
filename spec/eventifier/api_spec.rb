require 'spec_helper'

describe Eventifier::API do
  include Rack::Test::Methods

  let(:app)    { Eventifier::API.new }
  let(:user)   { double 'User' }
  let(:warden) { double 'Warden', authenticated?: true, user: user }

  describe 'GET /notifications' do
    let(:event)         { double 'Event', eventable_type: 'User', eventable: double, user: User.create!(name: 'Pat'), verb: :create }
    let(:notifications) { [double('Notification', id: 84, created_at: created_at, event: event)] }
    let(:created_at)    { 1.minute.ago }

    before :each do
      Rails.application.default_url_options = {host: 'eventifier.dev'}

      allow(user).to receive(:notifications_last_read_at).and_return(1)
      allow(notifications).to receive(:order).and_return(notifications)
      allow(notifications).to receive(:limit).and_return(notifications)
    end

    it 'returns 403 if there is no authenticated user' do
      allow(warden).to receive(:authenticated?).and_return(false)
      allow(warden).to receive(:user).and_return(nil)

      get '/notifications', {}, {'warden' => warden}

      expect(last_response.status).to eq(403)
    end

    it 'returns notifications as JSON' do
      allow(user).to receive(:notifications).and_return(notifications)

      get '/notifications', {}, {'warden' => warden}

      json = JSON.parse(last_response.body)
      expect(json['last_read_at']).to eq(1000)
      expect(json['notifications'].first['id']).to eq(84)
    end
  end

  describe 'POST /notifications/touch' do
    before :each do
      allow(user).to receive(:update_attribute).and_return(true)
    end

    it "updates the current user's notifications last read at" do
      expect(user).to receive(:update_attribute).
        with(:notifications_last_read_at, anything)

      post '/notifications/touch', {}, {'warden' => warden}
    end

    it "responds with JSON OK status" do
      post '/notifications/touch', {}, {'warden' => warden}

      expect(last_response.body).to eq ({'status' => 'OK'}.to_json)
    end
  end

  describe 'GET /preferences' do
    let(:preferences) { double :to_hashes => [{'foo' => 'bar'}] }

    before :each do
      allow(Eventifier::Preferences).to receive(:new).and_return(preferences)
    end

    it 'initializes the preferences with the logged in user' do
      expect(Eventifier::Preferences).to receive(:new).with(user).
        and_return(preferences)

      get '/preferences', {}, {'warden' => warden}
    end

    it "returns the settings hashes" do
      get '/preferences', {}, {'warden' => warden}

      expect(last_response.body).to eq ([{'foo' => 'bar'}].to_json)
    end
  end

  describe 'PUT /preferences' do
    let(:preferences) { double update: true }

    before :each do
      allow(Eventifier::Preferences).to receive(:new).and_return(preferences)
    end

    it 'initializes the preferences with the logged in user' do
      expect(Eventifier::Preferences).to receive(:new).with(user).
        and_return(preferences)

      put '/preferences', {preferences: {'foo' => ''}}, {'warden' => warden}
    end

    it 'saves the settings changes' do
      expect(preferences).to receive(:update).with('foo' => '')

      put '/preferences', {preferences: {'foo' => ''}}, {'warden' => warden}
    end

    it "renders a JSON OK status" do
      put '/preferences', {preferences: {'foo' => ''}}, {'warden' => warden}

      expect(last_response.body).to eq ({'status' => 'OK'}.to_json)
    end
  end
end
