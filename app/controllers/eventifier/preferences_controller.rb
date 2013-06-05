class Eventifier::PreferencesController < Eventifier::ApplicationController
  def show
    render :json => Eventifier::Preferences.new(current_user).to_hashes
  end

  def update
    settings = Eventifier::NotificationSetting.for_user current_user
    settings.preferences['email'] ||= {}

    Eventifier::Preferences.new(current_user).to_hashes.each do |hash|
      settings.preferences['email'][hash[:key]] = !params[:preferences][hash[:key]].nil?
    end

    settings.save

    render :json => {'status' => 'OK'}
  end
end
