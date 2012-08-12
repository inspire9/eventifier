require 'spec_helper'

class Activity; end

describe Eventifier::EventTracking do
  let(:event_tracker) { Object.new.extend(Eventifier::EventTracking) }

  describe ".url" do
    it "should at the url form to a hash" do
      url_proc = -> activity { [activity.group, activity] }
      Eventifier::Event.should_receive(:add_url).with(Activity, url_proc)
      event_tracker.instance_variable_set(:@klasses, [Activity])

      event_tracker.url url_proc
    end

  end

end