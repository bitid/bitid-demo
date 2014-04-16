require 'test_helper'

class NonceTest < ActiveSupport::TestCase

  test "should create nonce" do
    nonce = Nonce.new(session_id:"abcd")
    assert nonce.save
    assert_equal 16, nonce.uuid.length
    assert_equal "abcd", nonce.session_id
  end

  test "should expire after 10 minutes" do
    nonce = Nonce.create(session_id:"123")
    assert !nonce.expired?

    nonce.created_at = 20.minutes.ago
    assert nonce.expired?
  end
end