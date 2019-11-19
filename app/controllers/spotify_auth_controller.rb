class SpotifyAuthController < ApplicationController
  def auth_callback
    puts 'here?'
    # what to do on fail? or decline?
    @user = current_user
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    @user.persist_spotify_data(spotify_user.to_hash)
    # render json: spotify_user.to_hash
    if session['path_before_spotify_auth'].present?
      redirect_to session['path_before_spotify_auth']
    else
      redirect_to '/'
    end
  end
end