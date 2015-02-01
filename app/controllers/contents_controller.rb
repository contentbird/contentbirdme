class ContentsController < ApplicationController

  def index
    result = cb_session.section_contents( params[:section_slug],
                                          context: [:channel, :sections],
                                          page: params[:page] )

    @meta     = result[:meta]
    @contents = result[:result]
    set_context result
  end

  def show
    result = cb_session.section_content( params[:section_slug],
                                         params[:content_slug],
                                         context: [:channel, :sections] )
    @content  = result[:result]
    set_context result
    render_content
  end

  def permalink
    result = cb_session.content(params[:content_slug], context: [:channel, :sections])
    @content  = result[:result]

    set_context result
    render_content
  end

  def new
    result = cb_session.new_section_content( params[:section_slug],
                                                      context: [:channel, :sections, :html] )

    @html_form  = result[:html]
    set_context result
  end

  def create
    result = cb_session.create_section_content( params[:section_slug],
                                                         params[:content],
                                                         context: [:channel, :sections, :html] )
    if result[:result]['errors']
      @html_form  = result[:html]
      set_context result
      render :new
    else
      redirect_to root_path, notice: 'Your content was created'
    end
  end

private

  def set_context result
    @channel  = result[:channel]
    @sections = result[:sections]
    @current_section = nil
    @sections.each do |section|
      (@current_section = section) if section['slug'] == params[:section_slug]
    end
  end

end