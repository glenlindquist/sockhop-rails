class ChannelsController < ApplicationController

  before_action :set_channel, except: [:create, :new, :index]

  def index
    @channel = Chanenel.new
    @channels = Channel.all
  end


  def show
    @current_votes = VotingService.new(channel: @channel).get_current_votes
  end


  def new
    @channel = Channel.new
  end


  def edit
  end


  def create
    @channel = Channel.new(channel_params)

    respond_to do |format|
      if @channel.save
        format.html { redirect_to @channel, notice: 'Channel was successfully created.' }
        format.json { render :show, status: :created, location: @channel }
      else
        format.html { render :new }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @channel.update(channel_params)
        format.html { redirect_to @channel, notice: 'Channel was successfully updated.' }
        format.json { render :show, status: :ok, location: @channel }
      else
        format.html { render :edit }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @channel.destroy
    respond_to do |format|
      format.html { redirect_to channels_url, notice: 'Channel was successfully destroyed.' }
      format.json { head :no_content }
    end
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
      result = SpotifyService.search(track_title: @track_title)
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
      params.require(:channel).permit(:name)
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