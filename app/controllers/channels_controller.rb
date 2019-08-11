class ChannelsController < ApplicationController
  # before_action :require_login, except: [:index, :new, :create]
  before_action :set_channel, except: [:create, :new, :index]
  before_action :authenticate_viewer, only: [:show]
  # before_action :has_channel_privileges?, except: [:index, :create, :new]
  # before_action :require_logout, only: [:new, :create]

  def index
    @channel = Channel.new
    @channels = Channel.all
  end

  def show
    @current_votes = VotingService.new(channel: @channel).get_current_votes
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
    # auth spotify before beginning this.
    @channel = Channel.new
  end

  def create
    @channel = Channel.create(channel_params)
    if @channel.persisted?
      join_channel!
      redirect_to channels_path(@channel), notice: 'channel created'
    else
      render 'new'
    end
  end

  def host
    @current_votes = VotingService.new(channel: @channel).get_current_votes
  end

  # post /channel/:id/vote
  def vote
    respond_to do |format|
      @vote = vote_params.to_h
      @vote[:vote_count] ||= 0
      result = VotingService.send_vote(channel: @channel, vote: @vote)
      puts result
      format.json {render json: result, status: :ok }
    end
  end

  # post /channel/:id/track
  def search_track
    respond_to do |format|
      @track_title = params[:track_title]
      result = SpotifySearchService.search(track_title: @track_title)
      format.json {render json: result, status: :ok, location: @channel }
    end
  end

  private
    def authenticate_viewer
      channel = Channel.find(params[:id])
      if session[:channel_id] != channel.id
        redirect_to join_channel_path, alert: 'log in to channel to view'
      end
    end

    def join_channel!
      session[:channel_id] = @channel.id
    end

    def leave_channel!
      session[:channel_id] = nil
    end

    def set_channel
      @channel = Channel.find(params[:id])
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