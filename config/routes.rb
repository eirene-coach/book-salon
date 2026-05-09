Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  authenticated :user, ->(u) { u.admin? } do
    namespace :admin do
      root to: "dashboard#index"
    end
  end

  authenticated :user do
    root to: "dashboard#index", as: :dashboard
  end

  unauthenticated do
    root to: "pages#landing", as: :landing
  end

  resources :payments, only: [:new] do
    collection do
      get :success
      get :fail
    end
  end

  resources :missions, only: [:show]
  resources :daily_contents, only: [] do
    resources :responses, only: [:create]
  end

  get '/my_journey', to: 'my_journey#index', as: :my_journey
  get '/my_journey/download', to: 'my_journey#download', as: :download_journey

  namespace :admin do
    resources :cohorts do
      resources :daily_contents, only: [:new, :create, :edit, :update, :destroy]
      resources :responses, only: [:update]
    end
    resources :programs
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
