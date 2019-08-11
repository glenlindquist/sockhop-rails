class SpotifyAuthController < ApplicationController
  def auth_callback
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    render json: spotify_user.to_hash
  end
end