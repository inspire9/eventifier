
describe Eventifier do
  let(:post) { mock_model('Post', :group => group) }
  let(:group)    { double('group', :user => owner,
    :members => [owner, member]) }
  let(:owner)    { User.make! }
  let(:member)   { double('member') }

  before :each do
    Eventifier::Notification.stub :create => true
  end

  context 'a new post' do
    let(:event) { Eventifier::Event.new :eventable => post, :verb => :create,
      :user => owner }

    it "notifies the members of the group" do
      Eventifier::Notification.should_receive(:create).
        with(:user => member, :event => event)
      ActiveRecord::Observer.with_observers(Eventifier::EventObserver) do
        event.save
      end
    end

    it "does not notify the person initiating the event" do
      Eventifier::Notification.should_not_receive(:create).
        with(:user => owner, :event => event)

      event.save
    end
  end

  context 'an existing post' do
    let(:event) { Eventifier::Event.new :eventable => post, :verb => :update,
      :user => owner }
    let(:guest) { double('guest') }

    before :each do
      post.group.stub :members => [owner, guest]
    end

    it "notifies the members of the post" do
      Eventifier::Notification.should_receive(:create).
        with(:user => guest, :event => event)
      ActiveRecord::Observer.with_observers(Eventifier::EventObserver) do
        event.save
      end
    end

    it "does not notify the person initiating the event" do
      Eventifier::Notification.should_not_receive(:create).
        with(:user => owner, :event => event)

      ActiveRecord::Observer.with_observers(Eventifier::EventObserver) do
        event.save
      end
    end
  end
  
  it "should create a notification for users of a post when it's changed" do
    post = event.eventable
    user = User.make!

    lambda { post.update_attribute :date, 5.days.from_now }.should change(user.notifications, :count).by(1)
  end

end