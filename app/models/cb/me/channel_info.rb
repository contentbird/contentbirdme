class CB::Me::ChannelInfo

  include CB::Client::Connection

  attr_reader :prefix

  def initialize prefix
    @prefix = prefix
  end

  def get
    conn   = get_connection(url: CREDS_API_URL.to_s)
    conn.basic_auth CREDS_API_URL.user, CREDS_API_URL.password
    perform_request(:get, conn, "/api/channel_info/#{prefix}")
  end

end