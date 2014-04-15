require 'spec_helper'

describe Eventifier::EventTranslator do
  let(:event)        { double payload: {object: eventable, event: :update,
   options: {foo: :bar}} }
  let(:eventable)    { double 'Eventable', user: user }
  let(:user)         { double 'User' }
  let(:relationship) { double 'Relationship', users: [group] }
  let(:group)        { double 'Group' }

  before :each do
    allow(ActiveSupport::Notifications::Event).to receive(:new).and_return event
    allow(Eventifier::EventBuilder).to receive(:store).and_return(true)
    allow(Eventifier::Relationship).to receive(:new).and_return(relationship)
  end

  describe '#translate' do
    it 'builds a new event' do
      expect(Eventifier::EventBuilder).to receive(:store).with(
        eventable, user, :update, eventable, {foo: :bar}
      )

      Eventifier::EventTranslator.new.translate
    end

    it 'calculates the groupable object if a group_by option is provided' do
      event.payload[:group_by] = :groupable

      expect(Eventifier::EventBuilder).to receive(:store).with(
        eventable, user, :update, group, {foo: :bar}
      )

      Eventifier::EventTranslator.new.translate
    end

    it 'finds the user via an association if provided' do
      event.payload[:user] = :person

      expect(Eventifier::EventBuilder).to receive(:store).with(
        eventable, group, :update, eventable, {foo: :bar}
      )

      Eventifier::EventTranslator.new.translate
    end

    it "creates an event when :if is set and returns true" do
      event.payload[:options][:if] = Proc.new { |object| true }

      expect(Eventifier::EventBuilder).to receive(:store).with(
        eventable, user, :update, eventable, {foo: :bar}
      )

      Eventifier::EventTranslator.new.translate
    end

    it "does not create an event when :if is set and returns false" do
      event.payload[:options][:if] = Proc.new { |object| false }

      expect(Eventifier::EventBuilder).to_not receive(:store)

      Eventifier::EventTranslator.new.translate
    end

    it "creates an event when :unless is set and returns false" do
      event.payload[:options][:unless] = Proc.new { |object| false }

      expect(Eventifier::EventBuilder).to receive(:store).with(
        eventable, user, :update, eventable, {foo: :bar}
      )

      Eventifier::EventTranslator.new.translate
    end

    it "does not create an event when :unless is set and returns true" do
      event.payload[:options][:unless] = Proc.new { |object| true }

      expect(Eventifier::EventBuilder).to_not receive(:store)

      Eventifier::EventTranslator.new.translate
    end
  end
end
