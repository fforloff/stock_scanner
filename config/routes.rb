Rails.application.routes.draw do
  resources :lists
  resources :prices
  resources :companies , :constraints => { :id => /.*/ } do
    resources :prices
    collection do
      get 'autocomplete'
    end 
  end
  resources :exchanges
end
