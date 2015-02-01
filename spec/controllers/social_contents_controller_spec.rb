require 'spec_helper'

describe SocialContentsController do

  describe "#index" do
    context 'given the request is about a social channel' do
      before do
        stub_channel_info "my-domain", 'social'
        CB::Client::Session.stub(:new).with(@channel_id, @channel_token, :test).and_return(@session_mock=double('cb session'))
      end

      it 'instantiates a CB client, sets the channel and retrieves the contents for the current channel' do
        @session_mock.stub(:contents).with(page: nil, context: [:channel]).and_return({  result:   ['two', 'contents'],
                                                                    channel:  {'css' => 'path/to/channel.css'},
                                                                    meta:     {'current_page' => 1, 'total_pages' => 2}
                                                                        })

        get :index

        assigns[:channel].should          eq({'css' => 'path/to/channel.css'})
        assigns[:meta].should             eq({'current_page' => 1, 'total_pages' => 2})
        assigns[:contents].should         eq ['two', 'contents']
        response.should render_template :index
      end
    end
    context 'given the request is about a website channel' do
      before do
        stub_channel_info "my-domain", 'website'
      end
      it 'redirects to homepage if the channel is not social' do
        CB::Client::Session.should_receive(:new).never
        get :index
        response.should redirect_to root_path
      end
    end
  end

  describe "#show" do
    context 'given the request is about a social channel' do
      before do
        stub_channel_info "my-domain", 'social'
        CB::Client::Session.stub(:new).with(@channel_id, @channel_token, :test).and_return(@session_mock=double('cb session'))
      end
      it 'instantiates a CB client, sets the channel and retrieves the content for the current channel and given content slug' do
        @session_mock.stub(:content).with('my-content-slug', context: [:channel]).and_return({result: 'the wanted content object'})

        get :show, id: 'my-content-slug'

        assigns[:content].should          eq 'the wanted content object'
        response.should                   render_template :show
      end

      context 'given the content is a link' do
        before do
          @link_content = {"published_at"=>"2014-04-28T09:19:06.000Z", "type"=>"link", "title"=>"my title", "slug"=>"my-title", "first_image"=>"url", "thumbnail"=>"//cb-dev.herokuapp.com/link-images/vimeo.jpg", "properties"=>{"url"=>{"title"=>"Url", "value"=>"http://vimeo.com/70280234", "type"=>"url", "i18n"=>true}, "comment"=>{"title"=>"Comment", "value"=>"", "type"=>"memo", "i18n"=>true}}}
          @session_mock.stub(:content).with('my-title', context: [:channel])
                                      .and_return({ result:   @link_content,
                                                  channel:  {'css' => 'path/to/channel.css'}})
        end
        context 'given the link has no comment' do
          it 'redirects to the link url rather than rendering the link content on a page' do
            get :show, id: 'my-title'
            assigns(:direct_redirect_url).should eq 'http://vimeo.com/70280234'
            response.should render_template :show
          end
        end

        context 'given the link has a comment' do
          before do
            @link_content['properties']['comment']['value'] = 'some insightful comment on TDD...'
          end
          it 'renders the show page' do
            get :show, id: 'my-title'
            response.should render_template :show
          end
        end
      end

    end

    context 'given the request is about a website channel' do
      before do
        stub_channel_info "my-domain", 'website'
      end
      it 'redirects to homepage if the channel is not social' do
        CB::Client::Session.should_receive(:new).never

        get :show, id: 'my-content-slug'

        response.should redirect_to root_path
      end
    end
  end
end