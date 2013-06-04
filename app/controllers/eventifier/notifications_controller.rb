class Eventifier::NotificationsController < Eventifier::ApplicationController
  def index
    @notifications = notifications
  end

  def touch
    current_user.update_attribute :notifications_last_read_at, Time.zone.now

    render :json => {'status' => 'OK'}
  end

  private

  def notifications
    scope = current_user.notifications.limit(per_page)
    scope = scope.where("created_at < ?", after) if params[:after]
    scope = scope.where(
      "created_at > ?", current_user.notifications_last_read_at
    ) if params[:recent]

    scope
  end

  def after
    Time.zone.at params[:after].to_i
  end

  def per_page
    (params[:limit] || 5).to_i
  end
end
