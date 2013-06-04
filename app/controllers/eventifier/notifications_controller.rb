class Eventifier::NotificationsController < Eventifier::ApplicationController
  def index
    @notifications = current_user.notifications.limit(5)
  end

  def touch
    current_user.update_attribute :notifications_last_read_at, Time.zone.now

    render :json => {'status' => 'OK'}
  end
end
