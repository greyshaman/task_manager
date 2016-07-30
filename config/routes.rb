Rails.application.routes.draw do
  scope module: 'web' do
    resources :users
    resources :tasks do
      member do
        post :start
        post :finish
        post :assign_to
      end
    end

    root to: 'welcome#index'
  end

  resources :sessions, only: [:new, :create, :destroy]
end
