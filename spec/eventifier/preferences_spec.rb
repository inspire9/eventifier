require 'spec_helper'

describe Eventifier::Preferences do
  let(:preferences) { Eventifier::Preferences.new double('User') }
  let(:settings)    { double 'Settings', :preferences => {} }

  before :each do
    Eventifier::NotificationMapping.stub :notification_mappings => {
      'create.posts'    => [:readers],
      'create.comments' => [{:post => :readers}]
    }
    Eventifier::NotificationSetting.stub :for_user => settings
  end

  describe '#to_hashes' do
    it "interprets each key" do
      preferences.to_hashes.collect { |hash| hash[:key] }.should == [
        'default',
        'create_posts_notify_readers',
        'create_comments_notify_post_readers'
      ]
    end

    it "sets values to true if unknown" do
      preferences.to_hashes.collect { |hash| hash[:value] }.
        should == [true, true, true]
    end

    it "sets values to true if known and true" do
      settings.preferences['email'] = {}
      settings.preferences['email']['create_posts_notify_readers'] = true

      preferences.to_hashes.collect { |hash| hash[:value] }.
        should == [true, true, true]
    end

    it "sets values to false if known and false" do
      settings.preferences['email'] = {}
      settings.preferences['email']['create_posts_notify_readers'] = false

      preferences.to_hashes.collect { |hash| hash[:value] }.
        should == [true, false, true]
    end

    it "returns keys if no translations available for labels" do
      preferences.to_hashes.collect { |hash| hash[:label] }.should == [
        'default',
        'create_posts_notify_readers',
        'create_comments_notify_post_readers'
      ]
    end

    it "matches translations for labels" do
      I18n.backend.reload!
      I18n.backend.store_translations :en, :events => {
        :labels => {
          :preferences => {
            'default'                             => 'All Events',
            'create_posts_notify_readers'         => 'New Posts',
            'create_comments_notify_post_readers' => 'New Comments'
          }
        }
      }

      preferences.to_hashes.collect { |hash| hash[:label] }.
        should == ['All Events', 'New Posts', 'New Comments']
    end
  end
end