Eventifier::Engine.routes.draw do
  resources :notifications, module: 'eventifier' do
    collection { post :touch }
  end
end
