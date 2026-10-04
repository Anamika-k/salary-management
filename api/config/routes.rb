Rails.application.routes.draw do
  # Devise mapping only; auth routes are declared explicitly below.
  devise_for :users, skip: :all

  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post "auth/sign_in", to: "auth/sessions#create"
        get "auth/me", to: "auth/sessions#show"
        delete "auth/sign_out", to: "auth/sessions#destroy"
      end

      resources :employees
      resources :departments, only: %i[index create update destroy]
      resource :filters, only: :show
    end
  end

  # Health check for load balancers and uptime monitors.
  get "up" => "rails/health#show", as: :rails_health_check
end
