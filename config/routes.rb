Rails.application.routes.draw do
  devise_for :users
  root to: 'static_pages#home'

  get 'users/:id', to: 'users#show', as: 'user'
  resources :users do
    resources :channels
  end
  # resources :channels
  get 'channels/:name', to: 'channels#show', as: 'channel_name'
  get 'channels/:name/host', to: 'channels#host', as: 'channel_host'
  post 'channels/:name/vote', to: 'channels#vote'
  post 'channels/:name/host/vote', to: 'channels#vote'
  post 'channels/:id/track', to: 'channels#search_track', as: 'spotify_track_search'

  get 'join', to: 'channel_sessions#new', as: 'join_channel'
  get 'leave', to: 'channel_sessions#destroy', as: 'leave_channel'
  resources :channel_sessions, only: [:new, :create, :destroy]
  # get 'login' => 'channel_sessions#new', :as => :login
  # post 'logout' => 'channel_sessions#destroy', :as => :logout

  get 'auth/spotify/callback', to: 'spotify_auth#auth_callback'
  post 'pusher/auth', to: 'pusher#auth'
  post 'pusher/presence_webhook', to: 'pusher#presence_webhook'
  post 'pusher/presence_channel', to: 'pusher#presence_webhook'
end
