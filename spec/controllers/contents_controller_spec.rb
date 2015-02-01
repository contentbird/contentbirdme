require 'spec_helper'

describe ContentsController do
  before do
    stub_channel_info "my-domain"
    CB::Client::Session.stub(:new).with(@channel_id, @channel_token, :test).and_return(@session_mock=double('cb session'))
  end

  describe "#index" do
    it 'instantiates a CB client and retrieves the contents for the current channel and given section slug' do
      @session_mock.stub(:section_contents)
                   .with('my-section-slug', context: [:channel, :sections], page: nil)
                   .and_return({result:   ['two', 'contents'],
                                channel:  {'css' => 'path/to/channel.css'},
                                sections: [ {'slug' => 'my-section-slug'},
                                            {'slug' => 'other-section'}],
                                meta:     {'current_page' => 1, 'total_pages' => 2}
                                })

      get :index, section_slug: 'my-section-slug'

      assigns[:meta].should             eq({'current_page' => 1, 'total_pages' => 2})
      assigns[:channel].should          eq({'css' => 'path/to/channel.css'})
      assigns[:contents].should         eq ['two', 'contents']
      assigns[:sections].should         eq [{'slug' => 'my-section-slug'}, {'slug' => 'other-section'}]
      assigns[:current_section].should  eq({'slug'  => 'my-section-slug'})
      response.should render_template :index
    end
  end

  describe "#show" do
    it 'instantiates a CB client and retrieves the content for the current channel and given section and content slugs' do
      @session_mock.stub(:section_content).with('my-section-slug', 'my-content-slug', context: [:channel, :sections])
                                          .and_return({ result:   'the wanted content object',
                                                        channel:  {'css' => 'path/to/channel.css'},
                                                      sections: [ {'slug' => 'my-section-slug'},
                                                                  {'slug' => 'other-section'} ] } )
      get :show, section_slug: 'my-section-slug', content_slug: 'my-content-slug'

      assigns[:channel].should          eq({'css' => 'path/to/channel.css'})
      assigns[:content].should          eq 'the wanted content object'
      assigns[:sections].should         eq [{'slug' => 'my-section-slug'}, {'slug' => 'other-section'}]
      assigns[:current_section].should  eq({'slug'  => 'my-section-slug'})
      response.should                   render_template :show
    end

    context 'the channel is a social one' do
      before do
        stub_channel_info "my-domain", 'social'
      end
      context 'given the content is a link' do
        before do
          @link_content = {"published_at"=>"2014-04-28T09:19:06.000Z", "type"=>"link", "title"=>"my title", "slug"=>"my-title", "first_image"=>"url", "thumbnail"=>"//cb-dev.herokuapp.com/link-images/vimeo.jpg", "properties"=>{"url"=>{"title"=>"Url", "value"=>"http://vimeo.com/70280234", "type"=>"url", "i18n"=>true}, "comment"=>{"title"=>"Comment", "value"=>"", "type"=>"memo", "i18n"=>true}}}
          @session_mock.stub(:section_content).with('my-section-slug', 'my-title', context: [:channel, :sections])
                                    .and_return({ result:   @link_content,
                                                  channel:  {'css' => 'path/to/channel.css'},
                                                  sections: [ {'slug' => 'my-section-slug'},
                                                              {'slug' => 'other-section'} ] } )
        end
        context 'given the link has no comment' do
          it 'redirects to the link url rather than rendering the link content on a page' do
            get :show, section_slug: 'my-section-slug', content_slug: 'my-title'

            assigns[:direct_redirect_url].should eq 'http://vimeo.com/70280234'
            response.should render_template :show
          end
        end

        context 'given the link has a comment' do
          before do
            @link_content['properties']['comment']['value'] = 'some insightful comment on TDD...'
          end
          it 'renders the show page' do
            get :show, section_slug: 'my-section-slug', content_slug: 'my-title'
            response.should render_template :show
          end
        end
      end
    end

    context 'the channel is a website' do
      before do
        stub_channel_info "my-domain", 'website'
      end
      context 'given the content is a link' do
        before do
          @link_content = {"published_at"=>"2014-04-28T09:19:06.000Z", "type"=>"link", "title"=>"my title", "slug"=>"my-title", "first_image"=>"url", "thumbnail"=>"//cb-dev.herokuapp.com/link-images/vimeo.jpg", "properties"=>{"url"=>{"title"=>"Url", "value"=>"http://vimeo.com/70280234", "type"=>"url", "i18n"=>true}, "comment"=>{"title"=>"Comment", "value"=>"", "type"=>"memo", "i18n"=>true}}}
          @session_mock.stub(:section_content).with('my-section-slug', 'my-title', context: [:channel, :sections])
                                    .and_return({ result:   @link_content,
                                                  channel:  {'css' => 'path/to/channel.css'},
                                                  sections: [ {'slug' => 'my-section-slug'},
                                                              {'slug' => 'other-section'} ] } )
        end
        
        context 'given the link has no comment' do
          it 'renders the link content on a page' do
            get :show, section_slug: 'my-section-slug', content_slug: 'my-title'

            assigns[:direct_redirect_url].should be_nil
            response.should render_template :show
          end
        end
      end
    end

  end

  describe "#permalink" do
    it 'instantiates a CB client and retrieves the content for the current channel and content slugs' do
      @session_mock.stub(:content).with('my-content-slug', context: [:channel, :sections])
                                  .and_return({ result:   'the wanted content object',
                                                channel:  {'css' => 'path/to/channel.css'},
                                                sections: [ {'slug' => 'my-section-slug'},
                                                            {'slug' => 'other-section'} ] } )
      get :permalink, content_slug: 'my-content-slug'

      assigns[:channel].should          eq({'css' => 'path/to/channel.css'})
      assigns[:content].should          eq 'the wanted content object'
      assigns[:sections].should         eq [{'slug' => 'my-section-slug'}, {'slug' => 'other-section'}]
      assigns[:current_section].should  be_nil
      response.should                   render_template :show
    end

    context 'given the content is a link and the channel is a messaging channel' do
      before do
        stub_channel_info "my-domain", 'messaging'
        @link_content = {"published_at"=>"2014-04-28T09:19:06.000Z", "type"=>"link", "title"=>"my title", "slug"=>"my-title", "first_image"=>"url", "thumbnail"=>"//cb-dev.herokuapp.com/link-images/vimeo.jpg", "properties"=>{"url"=>{"title"=>"Url", "value"=>"http://vimeo.com/70280234", "type"=>"url", "i18n"=>true}, "comment"=>{"title"=>"Comment", "value"=>"", "type"=>"memo", "i18n"=>true}}}
        @session_mock.stub(:content).with('my-title', context: [:channel, :sections])
                                  .and_return({ result:   @link_content,
                                                channel:  {'css' => 'path/to/channel.css'},
                                                sections: [ {'slug' => 'my-section-slug'},
                                                            {'slug' => 'other-section'} ] } )
      end
      context 'given the link has no comment' do
        it 'redirects to the link url rather than rendering the link content on a page' do
          get :permalink, content_slug: 'my-title'

          assigns[:direct_redirect_url].should eq 'http://vimeo.com/70280234'
          response.should render_template :show
        end
      end

      context 'given the link has a comment' do
        before do
          @link_content['properties']['comment']['value'] = 'some insightful comment on TDD...'
        end
        it 'renders the show page' do
          get :permalink, content_slug: 'my-title'
          response.should render_template :show
        end
      end
    end
  end

  describe "#new" do
    it 'instantiates a CB client and retrieves the content form for the given section slug' do
      @session_mock.stub(:new_section_content).with('my-section-slug', context: [:channel, :sections, :html])
                                              .and_return({result:   'the newly created content',
                                                            channel:  {'css' => 'path/to/channel.css'},
                                                            sections: [ {'slug' => 'my-section-slug'},
                                                                        {'slug' => 'other-section'} ],
                                                            html:     'the new content html form'} )
      get :new, section_slug: 'my-section-slug'

      assigns[:channel].should          eq({'css' => 'path/to/channel.css'})
      assigns[:sections].should         eq [{'slug' => 'my-section-slug'}, {'slug' => 'other-section'}]
      assigns[:current_section].should  eq({'slug'  => 'my-section-slug'})
      assigns[:html_form].should        eq 'the new content html form'
      response.should                   render_template :new
    end
  end

  describe '#create' do
    it 'instantiates a CB client and posts the content params to save the content, and redirects to home if success' do
      @session_mock.stub(:create_section_content).with('my-section-slug', {'some' => 'params'}, context: [:channel, :sections, :html])
                                                 .and_return({result:   {sucessful: 'the newly created content'},
                                                                  channel:  {'css' => 'path/to/channel.css'},
                                                                  sections: [ {'slug' => 'my-section-slug'},
                                                                              {'slug' => 'other-section'} ],
                                                                  html:     'the new content html form'} )
      post :create, section_slug: 'my-section-slug', content: {some: 'params'}

      response.should redirect_to(root_path)
      flash[:notice].should_not be_nil
    end

    it 'instantiates a CB client and posts the content params to save the content, and redirects to home if success' do
      @session_mock.stub(:create_section_content).with('my-section-slug', {'some' => 'params'}, context: [:channel, :sections, :html])
                                                 .and_return({result:   {'failed' => 'the newly created content',
                                                                                'errors' => ['activerecord', 'errors']},
                                                                  channel:  {'css' => 'path/to/channel.css'},
                                                                  sections: [ {'slug' => 'my-section-slug'},
                                                                              {'slug' => 'other-section'} ],
                                                                  html:     'the content html form with errors'} )
      post :create, section_slug: 'my-section-slug', content: {some: 'params'}

      assigns[:channel].should          eq({'css' => 'path/to/channel.css'})
      assigns[:sections].should         eq [{'slug' => 'my-section-slug'}, {'slug' => 'other-section'}]
      assigns[:current_section].should  eq({'slug'  => 'my-section-slug'})
      assigns[:html_form].should        eq 'the content html form with errors'
      response.should                   render_template :new
    end
  end
end