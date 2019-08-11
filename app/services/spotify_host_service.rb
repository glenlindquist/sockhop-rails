require 'rspotify'

class SpotifyHostService
  def self.host(options)
    self.new(options).host
  end

  def initialize(options)
    @user = options.fetch :user
    @channel = options.fetch :channel
    @spotify_user = RSpotify::User.new(@user.spotify_user_data)
    @playlist_name = "sockhop-#{@channel_name}"
    @redis = Redis.new
  end

  def host
    # init_playlist
    # clear_playlist
    # open_voting
    update_current_track
  end

  def init_playlist
    @playlist = get_or_create_playlist
  end

  def get_or_create_playlist
    offset = 0
    loop do
      set = @spotify_user.playlists(limit: 50, offset: offset)
      match = set.find{|playlist| playlist.name == @playlist.name}
      return match if match.present?

      offset += 50
      break if offset > 100000
      break if set.count < 50
    end
    @spotify_user.create_playlist!(@playlist_name, public: true)
  end

  def clear_playlist
    @playlist.replace_tracks!
  end

  def open_voting

  end

  def update_current_track
    persist_current_track
    broadcast_current_track
  end

  def persist_current_track
    @redis.set("#{@channel.id}_current_track", current_track.to_json)
  end

  def broadcast_current_track
    channels_client = init_pusher
    channels_client.trigger("#{@channel.id}_current_track", 'current_track',current_track)
  end

  def current_track
    #formats into more the key info for js to display.
    SpotifySearchService.format_track(@spotify_user.player.currently_playing)
  end


  def init_pusher
    Pusher::Client.new(
      app_id: ENV['pusher_app_id'],
      key: ENV['pusher_key'],
      secret: ENV['pusher_secret'],
      cluster: ENV['pusher_cluster'],
      use_tls: true
    )
  end

end