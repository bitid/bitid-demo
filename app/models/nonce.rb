class Nonce < ActiveRecord::Base
  belongs_to :user
  
  validates :uuid, presence: true, uniqueness: true
  validates :secret, presence: true, uniqueness: true

  before_validation :build

  def expired?
    self.created_at.to_i < Time.now.to_i - 600
  end

  private

  def build
    self.uuid = SecureRandom.hex(8) if self.uuid.nil?
    self.secret = SecureRandom.hex(32) if self.secret.nil?
  end
end