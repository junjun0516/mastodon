Rails.application.routes.draw do
  use_doorkeeper

  get '.well-known/host-meta', to: 'xrd#host_meta', as: :host_meta
  get '.well-known/webfinger', to: 'xrd#webfinger', as: :webfinger

  devise_for :users, path: 'auth', controllers: {
    sessions:           'auth/sessions',
    registrations:      'auth/registrations',
    passwords:          'auth/passwords'
  }

  resources :accounts, path: 'users', only: [:show], param: :username do
    resources :stream_entries, path: 'updates', only: [:show]
  end

  namespace :api do
    # PubSubHubbub
    resources :subscriptions, only: [:show]
    post '/subscriptions/:id', to: 'subscriptions#update'

    # Salmon
    post '/salmon/:id', to: 'salmon#update', as: :salmon

    # JSON / REST API
    resources :statuses, only: [:create, :show] do
      collection do
        get :home
        get :mentions
      end

      member do
        post :reblog
        post :favourite
      end
    end

    resources :follows,  only: [:create]

    resources :accounts, only: [:show] do
      member do
        get :statuses
        get :followers
        get :following

        post :follow
        post :unfollow
      end
    end
  end

  root 'home#index'
end