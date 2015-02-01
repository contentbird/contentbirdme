require 'spec_helper'

describe ApplicationController do
  controller do
    def index
      raise CB::Client::TimeoutError if params[:error_type] == 'timeout'
      raise CB::Client::NotFoundError if params[:error_type] == 'not_found'
      raise CB::Client::AppError if params[:error_type] == 'app'
      render nothing: true
    end
  end

  describe '#restrict_access' do
    it 'does not autorize non whitelisted IP for front' do
      with_constants  :IP_WHITELIST => {'9.9.9.9' => 'authorized IP'},
                      :IP_FILTERING => true do
        get :index
        response.body.should eq "IP 0.0.0.0 Not authorized"
      end
    end
  end

  describe '#retrieve_requester_info' do
    it 'retrieve channel info using service for the given subdomain and assigns @channel_id, @channel_token and @channel_type' do
      request.host = "nna.cb.me"
      CB::Me::ChannelInfo.stub(:new).with('nna').and_return double('channel_info', get: [true, {result: {'key' => 'id', 'secret_key' => 'access_token', 'type' => 'website'}}])

      get :index

      assigns(:channel_id).should eq 'id'
      assigns(:channel_token).should eq 'access_token'
      assigns(:channel_type).should eq 'website'
      response.status.should eq 200
    end

    it 'renders a 404 page if the channel info could not be retrieved' do
      request.host = "nna.cb.me"
      CB::Me::ChannelInfo.stub(:new).with('nna').and_return double('channel_info', get: [false, {error: :not_found, message: 'No channel matches this url prefix'}])

      get :index

      response.status.should eq 404
      response.should render_template 'errors/404'
    end

    it 'does not retrieve channel info using service when no subdomain is passed' do
      CB::Me::ChannelInfo.stub(:new).with('nna').should_receive(:get).never

      get :index

      response.status.should eq 404
    end
  end

  describe '#rescue_from CB::Client::XxxxxxError' do
    before do
      request.host = "nna.cb.me"
      CB::Me::ChannelInfo.stub(:new).with('nna').and_return double('channel_info', get: [true, {result: {'key' => 'id', 'secret_key' => 'access_token', 'type' => 'website'}}])
    end
    it 'renders 404 page when CB::Client::NotFoundError is raised' do
      get :index, error_type: 'not_found'
      response.status.should eq 404
    end
    it 'renders 500 page when CB::Client::AppError or CB::Client::TimeoutError is raised' do
      get :index, error_type: 'app'
      response.status.should eq 500
    end
    it 'renders 500 page when CB::Client::AppError or CB::Client::TimeoutError is raised' do
      get :index, error_type: 'timeout'
      response.status.should eq 500
    end
  end
end