class User < ActiveRecord::Base
  validates :btc, presence: true, uniqueness: true
  attr_accessible :btc, :name, :signin_count

  before_validation :verify_bitcoin_address

  private

  def verify_bitcoin_address
    Bitcoin::valid_address?(self.btc)
  end
end