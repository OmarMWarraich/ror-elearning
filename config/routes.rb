Rails.application.routes.draw do
  devise_for :users
  resources :categories
  resources :courses do
    resources :lessons, only: %i[index new create] do
      resources :lesson_completions, only: %i[create]
    end
    resources :enrollments, only: %i[index create]
    resources :reviews, only: %i[index create]
  end
  resources :lessons, only: %i[show edit update destroy]
  resources :enrollments, only: %i[show destroy]
  resources :reviews, only: %i[edit update destroy]
  get "/search", to: "courses#search"
  get "/dashboard", to: "dashboard#index", as: :dashboard

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  unauthenticated do
    devise_scope :user do
      root to: "devise/sessions#new", as: :unauthenticated_root
    end
  end

  authenticated :user do
    root to: "dashboard#index"
  end
end
