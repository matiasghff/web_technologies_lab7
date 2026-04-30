Rails.application.routes.draw do
  root "owners#index"

  resources :owners
  resources :pets
  resources :vets

  resources :appointments do
    resources :treatments, except: [ :index, :show ]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
