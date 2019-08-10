require 'rspotify'

class SpotifyService

  def self.search(options)
    self.new(options).search
  end

  def initialize(options)
    @track_title = options.fetch(:track_title)
    RSpotify::authenticate(ENV['spotify_client_id'], ENV['spotify_client_secret'])

  end

  def search

    tracks = RSpotify::Track.search(@track_title)

    formatted_tracks = tracks.map do |track|
      {
        album_name: track.album.name,
        image_sm: track.album.images.last,
        image_med: track.album.images.second || track.album.images.first,
        image_lg: track.album.images.first,
        artist: track.artists[0].name,
        duration_ms: track.duration_ms,
        duration_readable: readable_duration(track.duration_ms),
        uri: track.uri,
        id: track.id,
        name: track.name
      }
    end

    formatted_tracks
  end

  private

  def readable_duration(duration_ms)
    minutes = (duration_ms / 1000.0 / 60.0)
    seconds = (minutes - minutes.floor) * 60.0
    readable_minutes = minutes.floor < 10 ? "0#{minutes.floor}" : "#{minutes.floor}"
    readable_seconds = seconds.floor < 10 ? "0#{seconds.floor}" : "#{seconds.floor}"
    "#{readable_minutes}:#{readable_seconds}"
  end


end