Rails.application.routes.draw do
  scope module: 'web' do
    resources :users
    resources :tasks do
      member do
        post :start
        get  :start, as: :easy_start
        post :finish
        get  :finish, as: :easy_finish
        get  :reactivate, as: :easy_reactivate
        post :assign_to
      end
    end

    root to: 'welcome#index'
  end

  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"
  resources :sessions, only: [:create]
end
