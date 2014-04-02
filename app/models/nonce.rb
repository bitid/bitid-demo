class Nonce < ActiveRecord::Base
  validates :uuid, presence: true, uniqueness: true

  attr_accessible :uuid

  before_validation :populate_uuid

  private

  def populate_uuid
    self.uuid = SecureRandom.hex(8) if self.uuid.nil?
  end
end