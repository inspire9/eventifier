Eventifier::Engine.routes.draw do
  mount Eventifier::API.new => '/eventifier'
end
