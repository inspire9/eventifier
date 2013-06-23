Rails.application.routes.draw do
  root to: 'application#index'

  mount Eventifier::Engine => '/'
end
