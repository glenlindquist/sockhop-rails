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
    @playlist = get_or_create_playlist
    # clear_playlist
    update_current_track

    if HostWorker.cancelled?(@channel.current_jid)
      worker = HostWorker.perform_async(
        spotify_user_hash: @spotify_user.to_hash,
        channel_id: @channel.id,
        cooldown: 15000,
        playlist_id: @playlist.id
      )
      @channel.update(current_jid: worker)
    end

    self
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

  def update_current_track
    track = SpotifyUtilities::current_track(spotify_user: @spotify_user)
    RedisUtilities::change_current_track(@channel.name, track)
    PusherUtilities::broadcast_current_track(@channel.name, track)
  end


end