class Eventifier::API::TouchNotifications < Eventifier::API::Base
  def call
    user.update_attribute :notifications_last_read_at, Time.zone.now

    response.body = {'status' => 'OK'}

    super
  end
end
