class EventTracking
  include Eventifier::EventTracking

  def initialize
    # events_for Group do
    #   track_on [:create, :update, :destroy], :attributes => { :except => %w(updated_at) }
    #   notify :group => :members, :on => [:create, :update]
    # end
  end
end

EventTracking.new
