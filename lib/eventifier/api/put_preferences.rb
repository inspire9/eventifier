class Eventifier::API::PutPreferences < Eventifier::API::Base
  def call
    Eventifier::Preferences.new(user).update request.params['preferences'] || {}

    response.body = {'status' => 'OK'}

    super
  end
end
