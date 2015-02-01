require 'spec_helper'

describe HomeController do
  describe "#index" do
    context 'given a social channel' do
      before do
        stub_channel_info "fb-user", 'social'
      end
      it 'redirects to social_contents_controller#index' do
        get :index

        response.should redirect_to(social_contents_path)
      end
    end
    context 'given a website channel' do
      before do
        stub_channel_info "my-domain", 'website'
      end
      it 'instantiates a CB client and retrieves the home contents for the current channel' do
        CB::Client::Session.stub(:new).with(@channel_id, @channel_token, :test).and_return(session_mock=double('cb session'))
        session_mock.stub(:home_contents).with(context: [:channel, :sections], page: nil).and_return({result:   ['two', 'contents'],
                                                                                                      channel:  {'css' => 'path/to/channel.css'},
                                                                                                      sections: [ {'slug' => 'my-section-slug'},
                                                                                                                  {'slug' => 'other-section'}],
                                                                                                      meta:     {'current_page' => 1, 'total_pages' => 2}
                                                                                                      })

        get :index

        assigns[:contents].should         eq ['two', 'contents']
        assigns[:channel].should          eq({'css' => 'path/to/channel.css'})
        assigns[:sections].should         eq [{'slug' => 'my-section-slug'}, {'slug' => 'other-section'}]
        assigns[:current_section].should  eq({'slug' => 'my-section-slug'})
        assigns[:meta].should             eq({'current_page' => 1, 'total_pages' => 2})
        response.should render_template :index
      end
    end
  end
  describe '#robots' do
    it 'returns blank if channel is a website' do
      stub_channel_info "fb-user", 'website'
      get :robots
      response.body.should eq ''
    end
    it 'disallows all bots on all pages if the channel is social' do
      stub_channel_info "fb-user", 'social'
      get :robots
      response.body.should eq "User-agent: *\nDisallow: /"
    end
    it 'disallows all bots on all pages if the channel is email' do
      stub_channel_info "fb-user", 'email'
      get :robots
      response.body.should eq "User-agent: *\nDisallow: /"
    end
    it 'disallows all bots on all pages if the channel is anything else than website' do
      stub_channel_info "fb-user", 'somethingelse'
      get :robots
      response.body.should eq "User-agent: *\nDisallow: /"
    end
  end
end