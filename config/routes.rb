Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  resources :submissions, only: [:create]
  resources :propagations, only: [:create]

  resources :messages, only: [:create, :index] do
    collection do
      put :deliver
      put :report
      get :reports
    end
  end

  resources :nodes, only: [:index, :show] do
    collection do
      get :names
      get :me
      put :register_name
    end
  end

  resources :simulations, only: [:index] do
    collection do
      get :paths
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
