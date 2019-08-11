class ChannelsController < ApplicationController
  before_action :require_login, except: [:index, :new, :create]
  before_action :set_channel, except: [:create, :new, :index]
  before_action :has_channel_privileges?, except: [:index, :create, :new]
  before_action :require_logout, only: [:new, :create]

  def index
    @channel = Chanenel.new
    @channels = Channel.all
  end

  def show
    @current_votes = VotingService.new(channel: @channel).get_current_votes
  end

  def destroy
    logout if logged_in?
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
      auto_login(@channel)
      redirect_to(channel_host_path(@channel), notice: 'channel created')
    else
      redirect_to new_channel_path, alert: @channel.errors.full_messages
    end
  end

  def host
    
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
    # Use callbacks to share common setup or constraints between actions.
    def set_channel
      @channel = Channel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
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