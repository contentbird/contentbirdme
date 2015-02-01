class SocialContentsController < ApplicationController

  before_action :only_allow_social_channels

  def index
    result = cb_session.contents(page: params[:page], context: [:channel])
    @channel  = result[:channel]
    @meta     = result[:meta]
    @contents = result[:result]
  end

  def show
    result = cb_session.content(params[:id], context: [:channel])
    @channel  = result[:channel]
    @content  = result[:result]
    render_content
  end

private

  def only_allow_social_channels
    redirect_to root_path unless @channel_type == 'social'
  end

end