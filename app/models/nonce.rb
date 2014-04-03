class Nonce < ActiveRecord::Base
  validates :uuid, presence: true, uniqueness: true

  attr_accessible :uuid

  before_validation :populate_uuid

  def expired?
    self.created_at.to_i < Time.now.to_i - 600
  end

  private

  def populate_uuid
    self.uuid = SecureRandom.hex(8) if self.uuid.nil?
  end
end