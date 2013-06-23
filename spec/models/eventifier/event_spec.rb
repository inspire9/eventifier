require 'spec_helper'

describe Eventifier::Event do
  let(:event) { Fabricate(:event) }

  describe "#valid?" do
    it_requires_a  :user
    it_requires_an :eventable
    it_requires_a  :verb
  end

  describe ".find_all_by_eventable" do
    let(:eventable)  { Fabricate(:user) }
    let(:event)      { Fabricate(:event, :eventable => eventable) }

    it "should find the associated polymorphic eventable object" do
      alpha = Fabricate :event, :eventable => eventable
      beta  = Fabricate :event, :eventable => Fabricate(:user)

      Eventifier::Event.find_all_by_eventable(eventable).should == [alpha]
    end
  end
end
