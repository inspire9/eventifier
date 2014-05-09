class Eventifier::API::Base
  include Sliver::Action

  def skip?
    return false if user

    response.status = 403
    response.body   = ['Forbidden']

    true
  end

  def call
    response.status ||= 200
    response.body   ||= {}
    response.headers['Content-Type'] ||= 'application/json'

    if response.body.is_a?(String)
      response.body = [response.body]
    else
      response.body = [JSON.generate(response.body)]
    end
  end

  private

  def user
    return nil unless warden && warden.authenticated?(:user)

    warden.user(:user)
  end

  def warden
    environment['warden']
  end
end
