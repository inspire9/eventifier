require 'spec_helper'

describe 'System Events' do
  let(:owner)  { Fabricate(:user) }
  let(:reader) { Fabricate(:user) }
  let(:post)   { Fabricate(:post, :author => owner) }
  let(:event)  {
    Eventifier::Event.where(
      :verb => :log, :system => true, user_id: nil,
      :eventable_type => 'Post', :eventable_id => post.id
    ).first
  }

  before do
    Subscription.create! user: owner,  post: post
    Subscription.create! user: reader, post: post

    Eventifier::Notifier.new [Post], :readers, on: :log
  end

  it "logs an event" do
    Eventifier::EventBuilder.store post, nil, :log, nil, system: true

    event.should be_present
  end

  it "stores notifications for the readers" do
    Eventifier::EventBuilder.store post, nil, :log, nil, system: true
    ActiveSupport::Notifications.instrument(
      "log.posts.notification.eventifier",
      verb: :log, event: event, object: post
    )

    [owner, reader].each do |user|
      expect(Eventifier::Notification.where(
        :event_id => event.id, :user_id => user.id
      ).count).to eq 1
    end
  end
end
