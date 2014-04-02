require 'test_helper'

class BitidTest < ActiveSupport::TestCase

  setup do
    @nonce = Nonce.create
    @callback = "http://localhost:3000/callback"
    @uri = "bitid://login?x=fe32e61882a71074&c=http%3A%2F%2Flocalhost%3A3000%2Fcallback"
    @address = "1HpE8571PFRwge5coHiFdSCLcwa7qetcn"
    @signature = "HxIhHWBedUxNlSZThlMPsOvRBA8qXnuL3DGBTUU9tO6pSwrJd+2coBfrh4XXXnB2Ho+iKGZJt7/ZJAWGJS6OzPE="
  end

  test "should build uri" do
    bitid = Bitid.new(nonce:@nonce, callback:@callback)
    
    assert bitid.uri.present?
    assert_equal "bitid", bitid.uri.scheme
    assert_equal "login", bitid.uri.host

    params = CGI::parse(bitid.uri.query)
    assert_equal @nonce.uuid, params['x'].first
    assert_equal @callback, params['c'].first
  end

  test "should build qrcode" do
    bitid = Bitid.new(nonce:@nonce, callback:@callback)

    uri_encoded = URI.encode(bitid.uri.to_s)
    assert_equal "http://chart.apis.google.com/chart?cht=qr&chs=300x300&chl=#{uri_encoded}", bitid.qrcode
  end

  test "should verify uri" do 
    bitid = Bitid.new(address:@address, uri:@uri, signature:@signature, callback:@callback)
    assert bitid.uri_valid?
  end

  test "should fail uri verification if bad uri" do
    bitid = Bitid.new(address:@address, uri:'garbage', signature:@signature, callback:@callback)
    assert !bitid.uri_valid?
  end

  test "should fail uri verification if bad scheme" do
    bitid = Bitid.new(address:@address, uri:'http://login?x=fe32e61882a71074&c=http%3A%2F%2Flocalhost%3A3000%2Fcallback', signature:@signature, callback:@callback)
    assert !bitid.uri_valid?
  end

  test "should fail uri verification if bad action" do
    bitid = Bitid.new(address:@address, uri:'bitid://hack?x=fe32e61882a71074&c=http%3A%2F%2Flocalhost%3A3000%2Fcallback', signature:@signature, callback:@callback)
    assert !bitid.uri_valid?
  end

  test "should fail uri verification if nonce not found" do
    bitid = Bitid.new(address:@address, uri:'bitid://login?y=fe32e61882a71074&c=http%3A%2F%2Flocalhost%3A3000%2Fcallback', signature:@signature, callback:@callback)
    assert !bitid.uri_valid?
  end

  test "should fail uri verification if invalid callback url" do
    bitid = Bitid.new(address:@address, uri:'bitid://login?x=fe32e61882a71074&c=http%3A%2F%site%3A3000%2Fcallback', signature:@signature, callback:@callback)
    assert !bitid.uri_valid?
  end

  test "should verify signature" do
    bitid = Bitid.new(address:@address, uri:@uri, signature:@signature, callback:@callback)
    assert bitid.signature_valid?
  end

  test "should fail verification if bad signature" do
    bitid = Bitid.new(address:@address, uri:@uri, signature:"garbage", callback:@callback)
    assert !bitid.signature_valid?
  end

  test "should fail verification if bad address" do
    bitid = Bitid.new(address:"1Nu5mzpUD9A7daZ76QJEsBfkBjCWVLh7pJ", uri:@uri, signature:@signature, callback:@callback)
    assert !bitid.signature_valid?
  end
end