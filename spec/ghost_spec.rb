require 'spec_helper'

describe Eventifier::Ghost do
  it_requires_a :ghost_class
  it_requires_a :ghost_id
  it_requires_a :data_hash

  describe ".create_from_object" do
    subject     { Eventifier::Ghost }
    let(:post)  { Fabricate(:post) }

    it "should create a ghost when passed an object" do
      subject.should_receive(:create).with(:ghost_class => "Post", :ghost_id => post.id, :data_hash => post.serializable_hash)

      subject.create_from_object(post)
    end
  end

  describe "#ghost" do
    let(:post)  { Fabricate.build(:post, :id => 123) }
    subject     { Fabricate.build(:ghost, :data_hash => post.serializable_hash) }

    it "should be an object with the attributes of the undeleted object" do
      pending

      subject.ghost.class.should == Post
      subject.ghost.attributes.except("_type").should == post.serializable_hash
    end
  end
end
