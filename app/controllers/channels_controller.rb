class ChannelsController < ApplicationController
  before_action :set_channel, except: [:create, :new, :index]
  before_action :set_user, only: [:index, :new, :edit, :create, :update, :destroy]
  before_action :authenticate_viewer, only: [:show, :vote, :search_track]
  before_action :authenticate_host, only: [:host]
  before_action :authenticate_user!, only: [:edit, :destroy]
  before_action :check_user, except: [:show, :vote, :search_track]
  before_action :confirm_spotify_auth, only: [:host, :new]

  def index
    @channels = @user.channels
  end

  def show
    if @channel.user == current_user
      redirect_to channel_host_path(name: @channel.name) 
      return
    end
    @host_present = RedisUtilities::host_present?(@channel.name)
    @current_votes = RedisUtilities::current_votes(@channel.name)
    @current_track = RedisUtilities::current_track(@channel.name)
    @vote_status = RedisUtilities::voting_open?(@channel.name)
  end

  def destroy
    leave_channel!
    @channel.destroy
    respond_to do |format|
      format.html { redirect_to '/', notice: 'channel shut down' }
      format.json { head :no_content }
    end
  end

  def new
    @channel = Channel.new
  end

  def create
    @channel = @user.channels.create(channel_params)
    if @channel.persisted?
      join_channel!
      redirect_to channel_host_path(name: @channel.name), notice: 'channel created'
    else
      render 'new'
    end
  end

  def host
    @current_votes = RedisUtilities::current_votes(@channel.name)
    host = SpotifyHostService.host(user: current_user, channel: @channel)
    @current_track = RedisUtilities::current_track(@channel.name)
    @vote_status = RedisUtilities::voting_open?(@channel.name)
  end

  # post /channel/:id/vote
  def vote
    respond_to do |format|
      @vote = vote_params.to_h
      @vote[:vote_count] ||= 0
      if RedisUtilities::voting_open?(@channel.name)
        result = VotingService.vote(channel: @channel, vote: @vote)
      else
        result = "Voting closed"
      end
      puts result
      format.json {render json: result, status: :ok }
    end
  end

  # post /channel/:id/track
  def search_track
    respond_to do |format|
      @track_title = params[:track_title]
      result = SpotifySearchService.search(track_title: @track_title)
      format.json {render json: result, status: :ok, location: channel_name_path(name: @channel.name)}
    end
  end

  private
    def authenticate_viewer
      set_channel

      if @channel.blank?
        redirect_to('/', notice: 'no channel found') 
        return
      end

      if session[:channel_name] != @channel.name
        redirect_to join_channel_path, alert: 'log in to channel to view'
      end
    end

    def authenticate_host
      set_channel
      
      if @channel.blank?
        redirect_to('/', notice: 'no channel found') 
        return
      end

      if @channel.user != current_user
        redirect_to channel_name_path(name: @channel.name), alert: 'unauthorized action'
      end

      @user = @channel.user
      join_channel!

    end

    def join_channel!
      session[:channel_name] = @channel.name
    end

    def leave_channel!
      session[:channel_name] = nil
    end

    def set_channel
      @channel ||= Channel.find(params[:id]) if params[:id] 
      @channel ||= Channel.find_by(name: params[:name]) if params[:name]
    end

    def set_user
      @user = User.find(params[:user_id])
    end

    def confirm_spotify_auth
      return if current_user.spotify_user_data.present?
      session['path_before_spotify_auth'] = request.env['PATH_INFO']
      redirect_to '/auth/spotify'
      return
    end

    def channel_params
      params.require(:channel).permit(:name, :password, :password_confirmation)
    end

    def vote_params
      params.require(:vote).permit(
        :album_name,
        :album_images,
        :artist,
        :duration_ms,
        :duration_readable,
        :uri,
        :id,
        :name,
        :vote_count,
        image_sm: [
          :height,
          :url,
          :width
        ],
        image_med: [
          :height,
          :url,
          :width
        ],
        image_lg: [
          :height,
          :url,
          :width
        ],
      )
    end


end