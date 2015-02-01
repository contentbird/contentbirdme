require 'spec_helper'

describe CB::Me::ChannelInfo do

  subject { CB::Me::ChannelInfo.new('nna') }

  describe '#initialize' do
    it 'creates a new ChannelInfo service object with given prefix' do
      svc = CB::Me::ChannelInfo.new('toto')
      svc.prefix.should eq 'toto'
    end
  end

  describe '#get' do
    before do
      @stubbed_request = stub_request(:get, 'https://user:test@cb.com/api/channel_info/nna')
    end

    it 'makes an HTTP request to CB endpoint to get channel info and return key, secret key and type returned by WS' do
      @stubbed_request.to_return(status: 200, body:   {key: 'my_key', secret_key: 'my_secret', type: 'website'}.to_json)

      with_constants(:CREDS_API_URL => URI('https://user:test@cb.com')) { subject.get.should eq [true, {key: 'my_key', secret_key: 'my_secret', type: 'website'}] }
    end

    it 'returns error with message when WS replies with 404' do
      @stubbed_request.to_return(status: 404, body: {message: 'no channel with this prefix'}.to_json)

      with_constants(:CREDS_API_URL => URI('https://user:test@cb.com')) { subject.get.should eq [false, {message: 'no channel with this prefix'}] }
    end

    it 'returns WS message when WS replies with 500' do
      @stubbed_request.to_return(status: 500, body:   {message: 'an error occurred'}.to_json)

      with_constants(:CREDS_API_URL => URI('https://user:test@cb.com')) { subject.get.should eq [false, {message: 'an error occurred'}] }
    end

    it 'returns timeout message when WS timeout' do
      @stubbed_request.to_timeout

      with_constants(:CREDS_API_URL => URI('https://user:test@cb.com')) { subject.get.should eq [false, {message: 'Timeout'}] }
    end
  end
end