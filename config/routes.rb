require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  resources :products

  resource :cart, only: [:show, :create] do
    post :add_item, on: :collection
    delete :remove_item, path: ':product_id', on: :collection
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "rails/health#show"
end
