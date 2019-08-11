class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :check_user
  def show
    @channels = @user.channels
  end

  private
  def set_user
    @user = User.find(params[:id])
  end
end
