require 'spec_helper'

describe Eventifier::NotificationMapping do

  describe 'adding and finding' do
    it 'acts like a datasource' do
      Eventifier::NotificationMapping.add 'test', :relation

      Eventifier::NotificationMapping.find('test').should == :relation
    end
  end

  describe '.add' do
    it 'should act like a data source' do
      Eventifier::NotificationMapping.add('test', :relation)
    end
  end

  describe "#method_from_relation" do
    it "should call the string as a method when passed a string" do
      object = double('object', :mouse => 5)

      Eventifier::NotificationMapping.method_from_relation(object, :mouse).should == [5]
    end

    it "should string the methods when passed a hash" do
      object = double('object', :cat => (cat = double('cat', :mouse => 5)))

      Eventifier::NotificationMapping.method_from_relation(object, :cat => :mouse).should == [5]
    end
  end
end