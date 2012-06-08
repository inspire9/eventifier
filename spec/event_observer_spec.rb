require 'spec_helper'

describe Eventifier::EventObserver do

  describe "#add_notification" do
    pending
  end

  describe "#method_from_relation" do
    subject { Eventifier::EventObserver.instance }

    it "should call the string as a method when passed a string" do
      object = double('object', :mouse => 5)

      subject.method_from_relation(object, :mouse).should == [5]
    end

    it "should string the methods when passed a hash" do
      object = double('object', :cat => (cat = double('cat', :mouse => 5)))

      subject.method_from_relation(object, :cat => :mouse).should == [5]
    end
  end

end
