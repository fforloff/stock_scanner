Rails.application.routes.draw do
  resources :indices
  resources :lists
  resources :prices
  resources :companies , :constraints => { :id => /.*/ } do
    resources :prices
    collection do
      get 'autocomplete'
    end 
  end
  resources :exchanges
  root :to => 'indices#index'
end


