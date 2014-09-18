class Eventifier::API::GetPreferences < Eventifier::API::Base
  def call
    response.body = Eventifier::Preferences.new(user).to_hashes

    super
  end
end
