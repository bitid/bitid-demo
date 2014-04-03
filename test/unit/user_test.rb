require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "should create user" do
    user = User.new(btc:"1Q2TWHE3GMdB6BZKafqwxXtWAWgFt5Jvm3")
    assert user.save
  end
end