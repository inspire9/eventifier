module ControllerAuthenticationHelpers
  def sign_in(user = double('User', enrolled?: false))
    controller.stub current_user: user, authenticate_user!: true
  end

  def sign_out
    sign_in nil
  end
end

RSpec.configure do |config|
  config.include ControllerAuthenticationHelpers, type: :controller
  config.before(:each, type: :controller) { @routes = Eventifier::Engine.routes }
end
