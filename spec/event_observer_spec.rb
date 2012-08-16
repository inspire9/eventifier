require 'spec_helper'

describe Eventifier::EventObserver do
  subject { Eventifier::EventObserver.instance }

  describe "#method_from_relation" do
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
