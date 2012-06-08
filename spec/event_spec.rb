require 'spec_helper'

describe Eventifier::Event do
  let(:event) { Eventifier::Event.make! }

  describe "#valid?" do
    pending
    #it_requires_a   :user
    #it_requires_an  :eventable
    #it_requires_a   :verb
  end

  describe ".find_all_by_eventable" do

    let!(:eventable) {Post.make!}
    let(:event) {Eventifier::Event.make! :eventable => eventable}

    it "should find the associated polymorphic eventable object" do
      lambda do
        Eventifier::Event.make! :eventable => Post.make!
        event
      end.should change(Eventifier::Event, :count).by(2)

      Eventifier::Event.find_all_by_eventable(eventable).length.should == 1
    end
  end

end
