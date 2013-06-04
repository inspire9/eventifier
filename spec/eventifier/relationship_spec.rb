require 'spec_helper'

describe Eventifier::Relationship do
  describe '#users' do
    it "should call the string as a method when passed a string" do
      object = double('object', :mouse => 5)

      Eventifier::Relationship.new(object, :mouse).users.should == [5]
    end

    it "should string the methods when passed a hash" do
      object = double('object', :cat => (cat = double('cat', :mouse => 5)))

      Eventifier::Relationship.new(object, :cat => :mouse).users.should == [5]
    end
  end
end