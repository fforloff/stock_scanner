Rails.application.routes.draw do
  resources :prices
  resources :companies , :constraints => { :id => /.*/ } do
    resources :prices
  end
  resources :exchanges
end
