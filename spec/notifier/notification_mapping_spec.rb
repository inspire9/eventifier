require 'spec_helper'

describe Eventifier::NotificationMapping do

  describe 'adding and finding' do
    it 'acts like a datasource' do
      Eventifier::NotificationMapping.add 'test', :relation

      expect(Eventifier::NotificationMapping.find('test')).to eq [:relation]
    end

    it "appends further relations" do
      Eventifier::NotificationMapping.notification_mappings.clear

      Eventifier::NotificationMapping.add 'test', :relation_a
      Eventifier::NotificationMapping.add 'test', :relation_b

      expect(Eventifier::NotificationMapping.find('test')).
      to eq [:relation_a, :relation_b]
    end
  end

  describe '.add' do
    it 'should act like a data source' do
      Eventifier::NotificationMapping.add('test', :relation)
    end
  end
end
