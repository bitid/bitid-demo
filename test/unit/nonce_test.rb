require 'test_helper'

class NonceTest < ActiveSupport::TestCase

  test "should create nonce" do
    nonce = Nonce.new
    assert nonce.save
    assert_equal 16, nonce.uuid.length
  end
end