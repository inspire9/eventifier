require 'spec_helper'

describe Eventifier::EventHelper do

  class TestClass
    def self.helper_method(*args)
      ;
    end

    include Eventifier::EventHelper
  end

  let(:verb) { "update" }
  let(:change_data) { { } }
  let(:event) { double("Event", :verb => verb, :eventable_type => "Object", :change_data => change_data, :user => double("user", :name => "Willy")) }
  let!(:helper) { TestClass.new }

  before do
    helper.stub :replace_vars => double("String", :html_safe => true)
  end

  describe ".event_message" do
    subject { helper.event_message event }

    context "with event verb create" do
      let(:verb) { "create" }

      it "should hit the I18n verb definition for create & destroy" do
        I18n.should_receive(:translate).with("events.object.create", :default => :"events.default.create", "user.name" => "Willy", :"event.type" => "Object")

        subject
      end

      it "should pass the I18n translation to the replace_vars method" do
        I18n.should_receive(:translate).with("events.object.create", :default => :"events.default.create", "user.name" => "Willy", :"event.type" => "Object").and_return("A message")
        helper.should_receive(:replace_vars).with "A message", event

        subject
      end
    end

    context "with event verb update" do
      let(:verb) { "update" }

      context "multiple updates" do
        let(:change_data) { { :name => ["Lol", "Omg Lol"] } }

        it "should specify single on the verb for the I18n definition on update when there are just a single change" do
          I18n.should_receive(:translate).with("events.object.update.single", :default => :"events.default.update", "user.name" => "Willy", :"event.type" => "Object")

          subject
        end
      end

      context "multiple updates" do
        let(:change_data) { { :name => ["Lol", "Omg Lol"], :address => ["old", "new"] } }

        it "should specify single on the verb for the I18n definition on update when there are just a single change" do
          I18n.should_receive(:translate).with("events.object.update.multiple", :default => :"events.default.update", "user.name" => "Willy", :"event.type" => "Object")

          subject
        end

      end
    end

  end
end
