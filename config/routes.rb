Rails.application.routes.draw do
  scope module: 'web' do
    resources :users do
      resources :tasks
    end

    root to: 'welcome#index'
  end

  resources :sessions, only: [:new, :create, :destroy]
end
