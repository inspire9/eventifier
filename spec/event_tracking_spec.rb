require 'spec_helper'

class Activity; end

describe Eventifier::EventTracking do
  let(:event_tracker) { Object.new.extend(Eventifier::EventTracking) }

  describe ".url" do
    it "should at the url form to a hash" do
      url_proc = -> activity { [activity.group, activity] }
      event_tracker.instance_variable_set(:@klasses, [Activity])

      event_tracker.url url_proc

      expect(Eventifier::EventTracking.url_mappings[:activity]).to eq url_proc
    end

  end

end
