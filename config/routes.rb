Rails.application.routes.draw do
  scope module: 'web' do
    resources :users
    resources :tasks

    root to: 'welcome#index'
  end

  resources :sessions, only: [:new, :create, :destroy]
end
