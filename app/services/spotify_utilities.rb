require 'rspotify'

module SpotifyUtilities
  extend self

  def current_track(options)
    player = options.fetch(:player, nil)
    spotify_user = options.fetch(:spotify_user, nil)
    player ||= spotify_user.player
    if player
      return SpotifyUtilities::format_track(player.currently_playing)
    end
    blank_track
  end

  def format_track(track)
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

  def blank_track
    {
      album_name: "",
      image_sm: "",
      image_med: "",
      image_lg: "",
      artist: "",
      duration_ms: "",
      duration_readable: "",
      uri: "",
      id: "",
      name: "",
    }
  end

  def readable_duration(duration_ms)
    minutes = (duration_ms / 1000.0 / 60.0)
    seconds = (minutes - minutes.floor) * 60.0
    readable_minutes = minutes.floor < 10 ? "0#{minutes.floor}" : "#{minutes.floor}"
    readable_seconds = seconds.floor < 10 ? "0#{seconds.floor}" : "#{seconds.floor}"
    "#{readable_minutes}:#{readable_seconds}"
  end

end