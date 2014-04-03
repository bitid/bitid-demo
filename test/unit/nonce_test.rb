require 'test_helper'

class NonceTest < ActiveSupport::TestCase

  test "should create nonce" do
    nonce = Nonce.new
    assert nonce.save
    assert_equal 16, nonce.uuid.length
  end

  test "should expire after 10 minutes" do
    nonce = Nonce.create
    assert !nonce.expired?

    nonce.created_at = 20.minutes.ago
    assert nonce.expired?
  end
end