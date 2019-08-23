require 'rspotify'

class SpotifySearchService

  def self.search(options)
    self.new(options).search
  end

  def initialize(options)
    @track_title = options.fetch(:track_title)
    RSpotify::authenticate(ENV['spotify_client_id'], ENV['spotify_client_secret'])
  end

  def search
    tracks = RSpotify::Track.search(@track_title)
    formatted_tracks = tracks.map {|track| SpotifyUtilities::format_track(track)}
    formatted_tracks
  end

end