Eventifier::Engine.routes.draw do
  resources :notifications, module: 'eventifier' do
    collection { post :touch }
  end

  resource :preferences, module: 'eventifier'
end
