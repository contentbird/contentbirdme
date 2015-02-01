# used to stub constants global and local
def parse(constant)
  source, _, constant_name = constant.to_s.rpartition('::')
  [source.constantize, constant_name]
end

def with_constants(constants, &block)
  saved_constants = {}
  constants.each do |constant, val|
    source_object, const_name = parse(constant)
    saved_constants[constant] = source_object.const_get(const_name)
    Kernel::silence_warnings { source_object.const_set(const_name, val) }
  end

  begin
    block.call
  ensure
    constants.each do |constant, val|
      source_object, const_name = parse(constant)
      Kernel::silence_warnings { source_object.const_set(const_name, saved_constants[constant]) }
    end
  end
end

def freeze_time datetime=1.day.ago
  Time.stub(:now).and_return(datetime)
  datetime
end

def unfreeze_time
  Time.unstub(:now)
end

def stub_channel_info url_prefix, type='website'
  request.host   = "#{url_prefix}.cb.me"
  @channel_id    = "key_#{url_prefix}"
  @channel_token = "secret_#{url_prefix}"
  @channel_type  = type
  CB::Me::ChannelInfo.stub(:new).with(url_prefix).and_return double('channel_info', get: [true, {result: {'key' => @channel_id, 'secret_key' => @channel_token, 'type' => @channel_type}}])
end
