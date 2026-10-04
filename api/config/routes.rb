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

      resources :employees do
        resources :salaries, only: %i[index create], controller: "employee_salaries" do
          get :breakdown, on: :collection
        end
        resources :audit_logs, only: :index
      end
      resources :departments, only: %i[index create update destroy]
      resource :filters, only: :show
      resources :salary_components, only: :index
      resources :salary_structures, only: %i[index show] do
        get :preview, on: :member
        resources :components, only: :update, controller: "salary_structure_components"
      end
    end
  end

  # Health check for load balancers and uptime monitors.
  get "up" => "rails/health#show", as: :rails_health_check
end
