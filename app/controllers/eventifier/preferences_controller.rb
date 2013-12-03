class Eventifier::PreferencesController < Eventifier::ApplicationController
  def show
    render :json => preferences.to_hashes
  end

  def update
    preferences.update params[:preferences] || {}

    render :json => {'status' => 'OK'}
  end

  private

  def preferences
    Eventifier::Preferences.new(current_user)
  end
end
