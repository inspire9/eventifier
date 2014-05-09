class Eventifier::API::GetNotifications < Eventifier::API::Base
  include Eventifier::API::View

  def call
    render 'eventifier/notifications/index',
      notifications: notifications, user: user

    super
  end

  private

  delegate :params, to: :request

  def notifications
    scope = user.notifications.order("eventifier_notifications.created_at DESC").limit(per_page)
    scope = scope.where("eventifier_notifications.created_at < ?", after) if params['after']
    scope = scope.where("eventifier_notifications.created_at > ?", since) if params['since']
    scope = scope.where(
      "eventifier_notifications.created_at > ?", user.notifications_last_read_at
    ) if params['recent']

    scope
  end

  def after
    Time.zone.at params['after'].to_i
  end

  def per_page
    (params['limit'] || 5).to_i
  end

  def since
    Time.zone.at params['since'].to_i
  end
end
