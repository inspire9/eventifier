require 'spec_helper'

describe Eventifier::Event do
  let(:event) { Fabricate(:event) }

  describe "#valid?" do
    pending
    #it_requires_a   :user
    #it_requires_an  :eventable
    #it_requires_a   :verb
  end

  describe '.add_url' do
    it "should send add_url to each of it's observers with params" do
      url_proc = -> activity { [activity.group, activity] }
      observer = double('Observer')
      Eventifier::Event.stub :observer_instances => [observer]

      observer.should_receive(:add_url).with(Object, url_proc)

      Eventifier::Event.add_url Object, url_proc
    end
  end

  describe ".find_all_by_eventable" do
    let!(:eventable)  { Fabricate(:post) }
    let(:event)       { Fabricate(:event, :eventable => eventable) }

    it "should find the associated polymorphic eventable object" do
      lambda do
        Fabricate(:event, :eventable => Fabricate(:post))
        event
      end.should change(Eventifier::Event, :count).by(2)

      Eventifier::Event.find_all_by_eventable(eventable).length.should == 1
    end
  end

end
