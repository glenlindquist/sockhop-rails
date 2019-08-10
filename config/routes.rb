Rails.application.routes.draw do
  root 'votes#index'

  resources :votes

  resources :channels
  post 'channels/:id/vote', to: 'channels#vote'
  post 'channels/:id/track', to: 'channels#search_track', as: 'spotify_track_search'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
