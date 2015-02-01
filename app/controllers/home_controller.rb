class HomeController < ApplicationController

  def index
    return redirect_to(social_contents_path) if @channel_type == 'social'
    result = cb_session.home_contents(context: [:channel, :sections], page: params[:page])
    @contents = result[:result]
    @channel  = result[:channel]
    @sections = result[:sections]
    @meta     = result[:meta]
    @current_section = @sections.first
  end

  def robots
  	render text: (@channel_type == 'website' ? '' : "User-agent: *\nDisallow: /"), layout: false, content_type: "text/plain"
  end

end