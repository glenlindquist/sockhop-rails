require 'rspotify/oauth'

Rails.application.config.to_prepare do
  OmniAuth::Strategies::Spotify.include SpotifyOmniauthExtension
end 

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :spotify,
    ENV['spotify_client_id'],
    ENV['spotify_client_secret'], 
    scope: [
      'user-read-email',
      'user-read-private',
      'user-modify-playback-state',
      'playlist-modify-public',
      'playlist-read-private',
      'playlist-modify-private',
      'user-read-currently-playing',
      'user-read-playback-state',
      'user-read-recently-played',
    ].join(' ')
  )

end
