require 'rspotify'

class SpotifyHostService

  attr_reader :playlist

  def self.host(options)
    self.new(options).host
  end

  def initialize(options)
    @user = options.fetch :user
    @channel = options.fetch :channel
    @spotify_user = RSpotify::User.new(@user.spotify_user_data)
    @playlist_name = "sockhop-#{@channel.name}"
    @redis = Redis.new
  end

  def host
    init_playlist
    # clear_playlist
    # open_voting
    update_current_track

    # TODO: Implement w/ sidekiq
    worker = HostWorker.perform_async(
      spotify_user_hash: @spotify_user.to_hash,
      channel_id: @channel.id
    )
    
    @channel.update(current_jid: worker)
    # @current_track_poller = CurrentTrackPoller.perform(@spotify_user, @channel)
    # TODO: ON EXIT!
    # @current_track_poller.cancel!

    self
  end

  def init_playlist
    @playlist = get_or_create_playlist
  end

  def get_or_create_playlist
    offset = 0
    loop do
      # can only grab 50 playlists / request.
      # keep polling until all playlists have been checked.

      playlists = @spotify_user.playlists(limit: 50, offset: offset)
      match = playlists.find{|playlist| playlist.name == @playlist_name}
      return match if match.present?

      offset += 50
      break if offset >= 100000
      break if playlists.length < 50
    end
    @spotify_user.create_playlist!(@playlist_name, public: true)
  end

  def clear_playlist
    @playlist.replace_tracks!([])
  end

  def open_voting

  end

  def update_current_track
    persist_current_track
    broadcast_current_track
  end

  def persist_current_track
    @redis.set("#{@channel.name}_current_track", current_track.to_json)
  end

  def broadcast_current_track
    channels_client = init_pusher
    channels_client.trigger(@channel.name, 'current_track', current_track)
  end

  def current_track
    #formats into more the key info for js to display.
    return {} if @spotify_user.player.blank?
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