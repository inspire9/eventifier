require 'spec_helper'

describe Eventifier::Relationship do
  describe '#key' do
    it "translates symbol relations to strings" do
      expect(Eventifier::Relationship.new(double, :mouse).key).to eq 'mouse'
    end

    it "translates hash relations to period-separated strings" do
      expect(Eventifier::Relationship.new(double, :cat => :mouse).key).
        to eq 'cat_mouse'
    end

    it "translates array relations to hyphen-separated strings" do
      expect(Eventifier::Relationship.new(double, [:cat, :mouse]).key).
        to eq 'cat-mouse'
    end
  end

  describe '#users' do
    it "should call the string as a method when passed a string" do
      object = double('object', :mouse => 5)

      expect(Eventifier::Relationship.new(object, :mouse).users).to eq [5]
    end

    it "should string the methods when passed a hash" do
      object = double('object', :cat => (cat = double('cat', :mouse => 5)))

      expect(Eventifier::Relationship.new(object, :cat => :mouse).users).to eq [5]
    end
  end
end
