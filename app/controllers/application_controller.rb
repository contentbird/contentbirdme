class ApplicationController < ActionController::Base
  include UserFilteringHelper

  protect_from_forgery  with: :exception
  before_action         :restrict_access, :retrieve_requester_info, :set_locale

  rescue_from CB::Client::NotFoundError,  with: :not_found
  rescue_from CB::Client::AppError,       with: :app_error
  rescue_from CB::Client::TimeoutError,   with: :timeout

  def retrieve_requester_info
    success, info = CB::Me::ChannelInfo.new(request.subdomain).get if request.subdomain.present?
    if success
      @channel_id    = info[:result]['key']
      @channel_token = info[:result]['secret_key']
      @channel_type  = info[:result]['type']
    else
      return not_found
    end
  end

private
  def set_locale
    unless Rails.env.test?
      I18n.locale = locale_from_accept_language_header || I18n.default_locale
    end
  end

  def cb_session
    @cb_client ||= CB::Client::Session.new(@channel_id, @channel_token, I18n.locale)
  end

  def not_found
    render 'errors/404', status: 404, layout: 'layouts/error'
  end

  def app_error
    render 'errors/500', status: 500, layout: 'layouts/error'
  end

  def timeout
    render 'errors/500', status: 500, layout: 'layouts/error'
  end

  def locale_from_accept_language_header
    return nil unless request.env['HTTP_ACCEPT_LANGUAGE'].present?
    parsed_locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    I18n.available_locales.include?(parsed_locale.to_sym) ? parsed_locale  : nil
  end

  def render_content
    if @channel_type != 'website' && @content['type'] == 'link' && @content['properties']['comment']['value'].blank?
      @direct_redirect_url = @content['properties']['url']['value']
    end
    render :show
  end

end
