require 'spec_helper'

describe Eventifier::Relationship do
  describe '#key' do
    it "translates symbol relations to strings" do
      Eventifier::Relationship.new(double, :mouse).key.should == 'mouse'
    end

    it "translates hash relations to period-separated strings" do
      Eventifier::Relationship.new(double, :cat => :mouse).key.
        should == 'cat.mouse'
    end

    it "translates array relations to hyphen-separated strings" do
      Eventifier::Relationship.new(double, [:cat, :mouse]).key.
        should == 'cat-mouse'
    end
  end

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