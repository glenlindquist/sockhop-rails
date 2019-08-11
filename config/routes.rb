Rails.application.routes.draw do
  root to: 'static_pages#home'

  resources :channels
  get 'channels/:id/host', to: 'channels#host', as: 'channel_host'
  post 'channels/:id/vote', to: 'channels#vote'
  post 'channels/:id/track', to: 'channels#search_track', as: 'spotify_track_search'

  resources :channel_sessions, only: [:new, :create, :destroy]
  get 'login' => 'channel_sessions#new', :as => :login
  post 'logout' => 'channel_sessions#destroy', :as => :logout

  get 'auth/spotify/callback', to: 'spotify_auth#auth_callback'

end
